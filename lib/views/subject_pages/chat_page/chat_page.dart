import 'package:ai_tutor1/backend/api_stuff.dart';
import 'package:ai_tutor1/colors.dart';
import 'package:ai_tutor1/firebase_stuff/utils.dart';
import 'package:ai_tutor1/imageAdresses.dart';
import 'package:ai_tutor1/models/chapter_info_model.dart';
import 'package:ai_tutor1/models/message_model.dart';
import 'package:ai_tutor1/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

String getAssId() {
  return "asst_kq80FvgUiK5KnoIDsmBgezve";
}

class ChatPage extends StatefulWidget {
  final String grade;
  final String subject;
  final String levelNumber;

  final String chapterName;
  final String chapterNumber;

  const ChatPage(
      {super.key,
      required this.grade,
      required this.subject,
      required this.chapterName,
      required this.chapterNumber,
      required this.levelNumber});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  String currentThreadId = "";

  // TODO: Implement function to get current assistant id@!
  final assId = getAssId();
  final storage = const FlutterSecureStorage();
  late Future<void> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = initSetup();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> initSetup() async {
    await Future.wait([
      _checkThreadsAndInitializeChat(),
      _storeLastAccessedInfo(),
    ]);
  }

  Future<void> _storeLastAccessedInfo() async {
    print("storing data");
    print(widget.grade);
    await storage.write(key: 'lastGrade', value: widget.grade);
    await storage.write(key: 'lastSubject', value: widget.subject);
    await storage.write(key: 'lastChapterNumber', value: widget.chapterNumber);
    await storage.write(key: 'lastChapterName', value: widget.chapterName);
    await storage.write(key: 'lastLevelNumber', value: widget.levelNumber);
  }

  Future<String?> getUserId() async {
    const storage = FlutterSecureStorage();
    try {
      // Assuming 'userToken' is the key you used to store the user ID
      String? userId = await storage.read(key: 'userToken');
      return userId;
    } catch (e) {
      print('Error reading user ID from secure storage: $e');
      return null;
    }
  }

  void _handleSubmitted(String text) async {
    _textController.clear();

    if (mounted) {
      setState(() {
        // _messages.insert(
        //     0,
        //     Message(
        //         content: text,
        //         role: "assistant")); // Add user's message to UI immediately
        _messages.add(Message(
            content: text, role: "user" // Assuming this is a user message
            ));
      });
    }
    _scrollToBottom();
    print(currentThreadId);
    print(text);

    //showCompletionModal(context, false, 0, 0);

    // if (mounted) {
    //   showCompletionModal(context, false, 0, 0);
    //   UserDataProvider userDataProvider =
    //       Provider.of<UserDataProvider>(context, listen: false);
    //   userDataProvider.updateStreak();
    // }

    // Insert typing indicator
    final typingMessage =
        Message(content: '...', role: 'assistant', isTyping: true);
    if (mounted) {
      setState(() {
        _messages.add(typingMessage);
      });
    }

    _scrollToBottom();

    try {
      // Call the function to send user response and get updated messages
      print(currentThreadId);
      final tempUpdatedMessages =
          await sendUserResponseAndGetThread(currentThreadId, text);
      List<Message> updatedMessages = (tempUpdatedMessages['messages'] ?? [])
          .where((message) => message != null) // Filter out null messages
          .map<Message>((message) {
            return Message(
              content: message['content']
                  as String, // Assuming 'content' is a String
              role: message['role']
                  as String, // Assuming 'role' is 'user' or 'assistant'
            );
          })
          .toList()
          .reversed
          .toList(); // Reverse the list if needed

      if (mounted) {
        // Update the UI with new messages
        setState(() {
          _messages = updatedMessages;
          _messages.add(typingMessage);
        });
      }
      _scrollToBottom();

      // Call the function to get assistant's response
      final tempAssistantResponse =
          await getAssResponse(currentThreadId, assId);
      final List<dynamic> tempAssistantMessages =
          tempAssistantResponse['messages'];
      final verdict = tempAssistantResponse['verdict'];
      final isLevelComplete = tempAssistantResponse['is_level_complete'];
      print(verdict);
      print(isLevelComplete);

      // if (mounted) {
      //   showCompletionModal(context, true, 4, 5);
      // }

      List<Message> assistantMessages = (tempAssistantMessages ?? [])
          .where((message) => message != null) // Filter out null messages
          .map<Message>((message) {
            return Message(
              content: message['content']
                  as String, // Assuming 'content' is a String
              role: message['role']
                  as String, // Assuming 'role' is 'user' or 'assistant'
            );
          })
          .toList()
          .reversed
          .toList(); // Reverse the list if needed

      // Update the UI with new messages
      if (mounted) {
        setState(() {
          _messages = assistantMessages;
        });
      }
      _scrollToBottom();

      if (verdict) {
        // ADD Stars
        print("Adding STARS");
        final userId = await getUserId();
        const starsToAdd = 10;
        print("Correct answer, + $starsToAdd stars");
        await addStars(userId!, starsToAdd);
        UserDataProvider userDataProvider =
            Provider.of<UserDataProvider>(context, listen: false);
        userDataProvider.updateStars(starsToAdd);

        // show Pop-up dialog to collect stars
        if (mounted && !isLevelComplete) {
          showDialog(
            barrierDismissible:
                false, // dialog wont close when user clicks outside, they have to click on the button.
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
                ),
                child: Container(
                  color: AppColors.tileColor,
                  constraints: const BoxConstraints(
                      maxWidth: 300,
                      minHeight: 250), // Adjust size to fit the image
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // Use the space needed by the child widgets
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize
                                .min, // Use the space needed by the child widgets
                            children: [
                              const Text(
                                "Congratulations!",
                                style: TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Pixelify',
                                  color: Colors
                                      .white, // Adjust text color as needed
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                "I'm so happy you could keep up!.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ), // Adjust text color as needed
                              ),
                              const SizedBox(height: 16.0),
                              Image.asset(
                                tutorAvatar, // Replace with your image URL
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                        //const Spacer(), // Use Spacer to push the button to the bottom of the dialog
                        Container(
                          width: double
                              .infinity, // Make the button as wide as the dialog
                          decoration: const BoxDecoration(
                            color:
                                AppColors.brightGreen, // Set the button color
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                            ), // Rounded edges for the button at the bottom
                          ),
                          child: TextButton(
                            child: const Text(
                              "Collect +10 Stars⭐",
                              style: TextStyle(
                                color: AppColors.backgroundColor,
                                fontSize: 20,
                              ), // Adjust text color as needed
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // Dismiss the dialog
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

          //   showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           backgroundColor: AppColors.tileColor,
          //           title: const Text(
          //             "Congratulations!",
          //             style: TextStyle(color: AppColors.brightGreen),
          //           ),
          //           content: const Text(
          //             "You got +10 xp for the correct answer.",
          //             style: TextStyle(color: AppColors.brightGreen),
          //           ),
          //           shape: const RoundedRectangleBorder(
          //             borderRadius: BorderRadius.all(
          //                 Radius.circular(40.0)), // Rounded edges
          //           ),
          //           actions: <Widget>[
          //             Container(
          //               width: double
          //                   .infinity, // Make the button as wide as the dialog
          //               decoration: const BoxDecoration(
          //                 color: Colors.green, // Set the button color
          //                 borderRadius: BorderRadius.only(
          //                   bottomLeft: Radius.circular(20.0),
          //                   bottomRight: Radius.circular(20.0),
          //                 ), // Rounded edges for the button at the bottom
          //               ),
          //               child: TextButton(
          //                 child: const Text(
          //                   "Collect +10 xp",
          //                   style: TextStyle(
          //                       color:
          //                           Colors.white), // Adjust text color as needed
          //                 ),
          //                 onPressed: () {
          //                   if (Navigator.of(context).canPop()) {
          //                     Navigator.of(context).pop(); // Dismiss the dialog
          //                   }
          //                 },
          //               ),
          //             ),
          //           ],
          //         );
          //       });
          // }
        }
      }

      if (isLevelComplete) {
        // update firebase
        print("Level Complete! Updating firebase...");
        // update level completion
        await updateLevelCompletion(
            (await getUserId())!,
            widget.grade,
            widget.subject,
            widget.chapterNumber.toString(),
            widget.levelNumber);
        // update stars and streak in provider
        if (mounted) {
          UserDataProvider userDataProvider =
              Provider.of<UserDataProvider>(context, listen: false);
          userDataProvider.updateStars(20); // ADDING ++20 on chapter completion
        }

        // update streak
        // NEED to:
        final userId = await getUserId();
        final streakData = await updateStreak(userId!);
        if (streakData['streakUpdated']) {
          // display a pop-up showing changed streak and come back tomorrow to extend
          int oldStreak = streakData['oldStreak'];
          int newStreak = streakData['currentStreak'];
          if (mounted) {
            UserDataProvider userDataProvider =
                Provider.of<UserDataProvider>(context, listen: false);
            userDataProvider.updateStreak();
          }

          if (mounted) {
            showCompletionModal(context, true, oldStreak, newStreak);
          }
        } else {
          // take back to levels page, chapters page if level 3 complete;
          if (mounted) {
            showCompletionModal(context, false, 0, 0); // '0, 0' as placeholders
          }
        }

        // update completion
        // Display a nice pop up and sheez;
        // GIVE DEM SOME DOPAMINE (zaza);
      }

      // List<Message> assistantMessages = (tempAssistantMessages ?? [])
      //     .where((message) => message != null) // Filter out null messages
      //     .map<Message>((message) {
      //       return Message(
      //         content: message['content']
      //             as String, // Assuming 'content' is a String
      //         role: message['role']
      //             as String, // Assuming 'role' is 'user' or 'assistant'
      //       );
      //     })
      //     .toList()
      //     .reversed
      //     .toList(); // Reverse the list if needed

      // // Update the UI with new messages
      // if (mounted) {
      //   setState(() {
      //     _messages = assistantMessages;
      //   });
      // }
      // _scrollToBottom();
    } catch (e) {
      print('Error handling submitted message: $e');
      // Optionally handle the error in the UI
    }
  }

  void showCompletionModal(
      BuildContext context, bool streakUpdated, int oldStreak, int newStreak) {
    double screenHeight = MediaQuery.of(context).size.height;
    double modalHeight =
        screenHeight * 0.8; // Example: 50% of the screen height
    String gender =
        Provider.of<UserDataProvider>(context, listen: false).userData!.gender;
    String avatarImagePath =
        (gender.toLowerCase() == "male") ? boyFull : girlFull;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        minHeight: modalHeight,
      ),
      builder: (BuildContext bc) {
        // Calculate the modal height as a percentage of screen height

        return Container(
          // Set a minimum height for the container, but allow it to be bigger if needed
          padding: const EdgeInsets.fromLTRB(30.0, 60, 30, 30),
          constraints: BoxConstraints(minHeight: modalHeight),
          color: AppColors.tileColor, // Adjust the color as necessary
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Text(
                  'Level Complete!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Pixelify",
                  ),
                  textAlign: TextAlign.center,
                ),
                if (streakUpdated) ...[
                  Text(
                    'Your streak has increased from $oldStreak to $newStreak!',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                ],
                Image.asset(
                  avatarImagePath, // Path to your AssetImage
                  width: screenHeight *
                      0.5, // 20% of screen height for image width
                  height: screenHeight *
                      0.5, // 20% of screen height for image height
                  fit: BoxFit
                      .cover, // Ensures the entire image is shown, might not fill the entire container
                ),
                const Text(
                  'Complete a level tomorrow to extend your streak.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                Container(
                  height: screenHeight * 0.1,
                  width:
                      double.infinity, // Make the button as wide as the dialog
                  margin: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0), // Horizontal margin for the button
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.brightGreen, // Button color
                      padding: const EdgeInsets.symmetric(
                          vertical: 15), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    child: const Text(
                      "Collect +20 ⭐",
                      style: TextStyle(
                          fontSize: 30, // Font size for button text
                          color: AppColors.backgroundColor, // Text color
                          fontFamily: 'Pixelify'),
                    ),
                    onPressed: () async {
                      if (mounted) {
                        Navigator.pop(context); // Dismiss the modal sheet
                      }
                      addStars((await getUserId())!, 20);
                    },
                  ),
                ),
                // ElevatedButton(
                //   child: const Text('Collect +20 stars'),
                //   onPressed: () async => {
                //     addStars((await getUserId())!, 20),
                //     if (mounted)
                //       {
                //         Navigator.pop(context),
                //       }
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      // Navigate back to the previous page after the modal is dismissed
      Navigator.pop(context); // to levels page
      //Navigator.popUntil(context, ModalRoute.withName('/home')); // to home
    });
  }

  Future<void> _checkThreadsAndInitializeChat() async {
    createSubjectDocument();
    final userId = await getUserId();
    final result = await onChatOpen(
        userId: userId!,
        grade: widget.grade,
        subject: widget.subject,
        chapterNumber: widget.chapterNumber,
        levelNumber: widget.levelNumber);
    List<Message> newMessages = (result['messages'] as List<dynamic>)
        .where((message) => message != null) // Filter out null messages
        .map<Message>((message) {
          return Message(
            content:
                message['content'] as String, // Assuming 'content' is a String
            role: message['role']
                as String, // Assuming 'role' is 'user' or 'assistant'
          );
        })
        .toList()
        .reversed
        .toList(); // Reverse the list if needed
    final threadId = result['thread_id'] as String? ?? 'default_thread_id';
    if (mounted) {
      setState(() {
        currentThreadId = threadId;
        _messages.addAll(newMessages);
      });
    }
    _scrollToBottom();
  }

  Future<void> _initChat() async {
    // Implement your logic for "init_chat"
    // User is chatting for the first time.
    // Need to create thread and initial prompting has to be done too.
    // need to update user store AND firebase too.
    print("need to init chat");
    print(widget.grade);
    try {
      //final chatService = ChatService('YOUR_BACKEND_BASE_URL');
      //final result = await chatService.initChat('USER_ID');
      final result = await initChat(widget.grade, widget.subject,
          widget.chapterNumber, widget.levelNumber);
      List<Message> newMessages = (result['messages'] as List<dynamic>)
          .where((message) => message != null) // Filter out null messages
          .map<Message>((message) {
            return Message(
              content: message['content']
                  as String, // Assuming 'content' is a String
              role: message['role']
                  as String, // Assuming 'role' is 'user' or 'assistant'
            );
          })
          .toList()
          .reversed
          .toList(); // Reverse the list if needed

      if (mounted) {
        setState(() {
          _messages.addAll(newMessages);
        });
      }
      _scrollToBottom();

      // get threadId, userid, assid and store in Firebase
      final threadId = result['thread_id'] as String? ?? 'default_thread_id';
      if (mounted) {
        setState(() {
          currentThreadId = threadId;
        });
      }
      String? userId = await getUserId();
      print(userId);
      print(currentThreadId);
      uploadThreadIdToFirebase(userId!, assId, widget.grade, widget.subject,
          widget.chapterNumber, widget.levelNumber, threadId);
      // TODO: Update Provider too. But for safety pull from firebase everytime.
    } catch (e) {
      print('Error initializing chat: $e');
      // Handle errors appropriately
    }
  }

  Future<void> _getChat(String? threadId) async {
    // Implement your logic for "get_chat"
    // User has chatted before.
    // Just get previous messages and display them.
    print("need to get chat");
    // TODO: Implement get chat. TO be called after every message sent.
    try {
      //final chatService = ChatService('YOUR_BACKEND_BASE_URL');
      //final result = await chatService.initChat('USER_ID');
      currentThreadId = threadId!;
      print(threadId);
      final result = await getChat(threadId);
      List<Message> newMessages = (result)
          .where((message) => message != null) // Filter out null messages
          .map<Message>((message) {
            return Message(
              content: message['content']
                  as String, // Assuming 'content' is a String
              role: message['role']
                  as String, // Assuming 'role' is 'user' or 'assistant'
            );
          })
          .toList()
          .reversed
          .toList(); // Reverse the list if needed

      //print(result);
      if (mounted) {
        setState(() {
          _messages.addAll(newMessages);
          //_messages = newMessages;
        });
      }
      _scrollToBottom();

      // get threadId, userid, assid and store in Firebase
    } catch (e) {
      print('Error initializing chat: $e');
      // Handle errors appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            _userDataFuture, // This should be the Future returned by initSetup
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // Check the connection state of the Future
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Data is still loading, show a loading indicator
            return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              appBar: AppBar(
                backgroundColor: AppColors.backgroundColor,
                foregroundColor: AppColors.brightGreen,
                title: Text(widget.chapterName),
                centerTitle: true,
              ),
              body: const Center(
                  child: CircularProgressIndicator()), // Loading indicator
            );
          } else {
            // Data is loaded, build the chat UI
            return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              appBar: AppBar(
                backgroundColor: AppColors.backgroundColor,
                foregroundColor: AppColors.brightGreen,
                title: Text(widget.chapterName),
                centerTitle: true,
              ),
              body: Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      bool isUserMessage = message.role == 'user';
                      if (isUserMessage) {
                        // Align user messages to the right without avatar
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: isUserMessage
                                  ? AppColors.userBubble
                                  : AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              message.content,
                              style: const TextStyle(
                                  fontSize: 20.0, color: Colors.white),
                            ),
                          ),
                        );
                      } else {
                        // Align other messages to the left with avatar
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: isUserMessage
                          //     ? MainAxisAlignment.end
                          //     : MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 12),
                            if (!isUserMessage) // Only add an avatar if it's not a user message
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                child: CircleAvatar(
                                  backgroundColor: AppColors.backgroundColor,
                                  backgroundImage: AssetImage(
                                      tutorAvatarZoom), // Example path to an asset image
                                  radius: 20,
                                ),
                              ),
                            const SizedBox(
                                width:
                                    0), // Space between avatar and message bubble
                            Flexible(
                              // Wrap the message container in a Flexible widget
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: isUserMessage
                                      ? AppColors.userBubble
                                      : AppColors.backgroundColor,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  message.content,
                                  style: const TextStyle(
                                      fontSize: 20.0, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  )),
                  const Divider(height: 1.0),
                  _buildTextComposer(),
                ],
              ),
            );
          }
        });
  }

  Widget _buildTextComposer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
        margin: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          color: AppColors.tileColor,
        ),
        height: 60,
        width: double.infinity,
        //color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(width: 15),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 15),
            FloatingActionButton(
              onPressed: () => _handleSubmitted(_textController.text),
              backgroundColor: AppColors.userBubble,
              elevation: 0,
              child: const Icon(Icons.send, color: Colors.black, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
