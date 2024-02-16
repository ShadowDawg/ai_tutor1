import 'package:ai_tutor1/backend/api_stuff.dart';
import 'package:ai_tutor1/colors.dart';
import 'package:ai_tutor1/imageAdresses.dart';
import 'package:ai_tutor1/models/user_data_model.dart';
import 'package:ai_tutor1/providers/data_provider.dart';
import 'package:ai_tutor1/providers/user_provider.dart';
import 'package:ai_tutor1/util_stuff/storage_utils.dart';
import 'package:ai_tutor1/views/chapters_page/chapters_page.dart';
import 'package:ai_tutor1/views/home_page/widgets.dart';
import 'package:ai_tutor1/views/user_stats/user_stats_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../subject_pages/chat_page/chat_page.dart'; // Import other pages similarly

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

class LearningHomePage extends StatefulWidget {
  const LearningHomePage({Key? key}) : super(key: key);

  @override
  _LearningHomePageState createState() => _LearningHomePageState();
}

class _LearningHomePageState extends State<LearningHomePage> {
  final _storage = const FlutterSecureStorage();

  // Fetch user stats (streak, Stars, gems)
  int userStreak = 5; // Placeholder value
  // int userStars = 1200; // Placeholder value
  int userStars = 0; // Placeholder INITIAL value
  int userGems = 50; // Placeholder value
  String userGrade = '';
  String userGender = '';
  // TODO: GET SUBJECT LIST SPECIFIC TO STUDENT GRADE
  List<String> subjectList = []; // Initialize as empty list
  late Future<void> _userDataFuture;

  // Whether to display "Pick up where you left off"
  bool hasLastLessonData = false;
  String lastGrade = '';
  String lastSubject = '';
  String lastChapterNumber = '';
  String lastChapterName = '';
  String lastLevelNumber = '';

  @override
  void initState() {
    super.initState();
    //initSetup();
    _userDataFuture = initSetup();
  }

  Future<void> initSetup() async {
    // //print("ayyy");

    await Future.wait([
      initUserData(),
      loadSubjectList(), // Assuming this is your method to load the subject list
    ]);

    // await initUserData(); // Ensure user data is fetched and stored first.
    // await fetchLastLessonData(); // Then fetch last lesson data.
    // await loadSubjectList(); // Finally, load the subject list.
    // String? userId = await _storage.read(key: "userToken");
    // if (userId != null) {
    //   initUserData().then((userData) {
    //     _userDataFuture = userData as Future<UserData?>;
    //     if (userData != null) {
    //       setState(() {
    //         userGrade = userData.grade;
    //       });
    //       loadSubjectList(userData.grade); // Pass grade directly to this method
    //     }
    //   });
    // }
    // await fetchLastLessonData();
  }

  Future<void> fetchLastLessonData() async {
    // Fetch last lesson data from secure storage
    lastGrade = await _storage.read(key: 'lastGrade') ?? '';
    lastSubject = await _storage.read(key: 'lastSubject') ?? '';
    lastChapterNumber = await _storage.read(key: 'lastChapterNumber') ?? '';
    lastChapterName = await _storage.read(key: 'lastChapterName') ?? '';
    lastLevelNumber = await _storage.read(key: 'lastLevelNumber') ?? '';
    print("fetching data");
    print(lastGrade);
    if (lastGrade.isNotEmpty &&
        lastSubject.isNotEmpty &&
        lastChapterName.isNotEmpty &&
        lastChapterNumber.isNotEmpty &&
        lastLevelNumber.isNotEmpty) {
      if (mounted) {
        setState(() {
          hasLastLessonData = true;
        });
      }
    }
  }

  Future<void> initUserData() async {
    String? userId = await _storage.read(key: "userToken");
    if (userId != null) {
      Map<String, dynamic> userDataMap = await fetchUserData(userId);
      // Create a UserData object
      UserData user = UserData(
        name: userDataMap['name'],
        grade: userDataMap['class'].toString(),
        section: userDataMap['section'],
        school: userDataMap['school'],
        admissionNumber: userDataMap['admissionNumber'],
        stars: userDataMap['stars'],
        streak: userDataMap['streak'],
        gender: userDataMap['gender'],
      );
      print(user);
      //_userDataFuture = user as Future<UserData?>;

      // userData = user;

      // Set user stats for homepage:
      int stars = userDataMap['stars']!;
      int streak = userDataMap['streak']!;
      setState(() {
        userStars = stars;
        userStreak = streak;
        userGrade = userDataMap['class'].toString();
        userGender = userDataMap['gender'];
      });
      // Use Provider to set user data
      if (mounted) {
        Provider.of<UserDataProvider>(context, listen: false).setUserData(user);
        fetchLastLessonData();
        loadSubjectList();
      }
      // After the user data is set, proceed with other operations.
    }
  }

  Future<void> loadSubjectList() async {
    // Access the provider
    final subjectProvider = Provider.of<dataProvider>(context, listen: false);

    // Check if the subject list is already loaded
    if (subjectProvider.subjectList.isEmpty) {
      // Subject list is empty, fetch from backend
      final grade =
          Provider.of<UserDataProvider>(context, listen: false).userData?.grade;
      print("fetching subject list from backend");
      try {
        List<String> fetchedSubjects = await getSubjectList(grade!);
        subjectProvider.subjectList =
            fetchedSubjects; // Update provider with fetched list
        setState(() {
          subjectList = fetchedSubjects;
        });
      } catch (e) {
        print('Error fetching subjects: $e');
        // Handle errors appropriately
      }
    } else {
      // Subject list is already loaded, just update local state
      setState(() {
        subjectList = subjectProvider.subjectList;
      });
    }
  }

  Future<void> loadUserStats() async {
    String? userId = await getUserId();
    if (userId != null) {
      try {
        // Stars
        final temp = await getUserStarsAndStreak(userId);
        int stars = temp['stars']!;
        int streak = temp['streak']!;
        setState(() {
          userStars = stars;
          userStreak = streak;
        });

        // ADD OTHER ATTRIBUTES HERE
      } catch (e) {
        print('Error fetching user stars: $e');
        // Handle errors appropriately
      }
    }
  }

  void navigateToLastLesson() {
    // Navigate to the ChatPage with the stored last lesson details
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                  grade: lastGrade,
                  subject: lastSubject,
                  chapterName: lastChapterName,
                  chapterNumber: lastChapterNumber,
                  levelNumber: lastLevelNumber,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _userDataFuture,
        builder: (context, snapshot) {
          // Check if the future is still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ignore: prefer_const_constructors
            return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: const Center(
                  child: CircularProgressIndicator()), // Loading indicator
            );
          }
          return Consumer<UserDataProvider>(
            builder: (context, userDataProvider, child) {
              UserData? userData = userDataProvider.userData;
              // You can now use userData to build your UI reactively.
              return Scaffold(
                backgroundColor: AppColors.backgroundColor,
                body: SafeArea(
                  child: ListView(
                    children: [
                      if (userData != null) ...[
                        const TitleBox(title: "Home"),
                        UserStatsCard(
                          username: userData.name,
                          streak: userDataProvider.streak,
                          stars: userDataProvider.stars,
                          avatarUrl: userData.gender.toLowerCase() == "male"
                              ? boyAvatar // Replace with actual URL for boy avatar
                              : girlAvatar, // Replace with actual URL for girl avatar
                        ),
                        // const TitleBox(title: "Your Stats"),
                        // ContinueLearningCard(
                        //     hasLastLessonData: hasLastLessonData,
                        //     onContinue: navigateToLastLesson,
                        //     onStartNew: () {}),

                        // Divider with label 'Subjects'
                        // const Padding(
                        //   padding: EdgeInsets.symmetric(vertical: 8.0),
                        //   child: Text(
                        //     'Start a new topic',
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(
                        //       fontSize: 20.0,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        const TitleBox(title: 'Start a new topic'),
                        // Grid of subject tiles
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, // Change to 1 for larger tiles
                            childAspectRatio:
                                3.0, // Adjust aspect ratio for desired size
                          ),
                          itemCount: subjectList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CategoryCard(
                              title: subjectList[index].toUpperCase(),
                              imageUrl: scienceBG,
                              //description: subjectList[index]['description']!,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChaptersPage(
                                            subject: subjectList[index],
                                            grade: userData!.grade,
                                          )),
                                );
                              },
                            );
                          },
                        ),
                      ],
                      // const Divider(
                      //   color:
                      //       Colors.grey, // Adjust the divider color as needed
                      //   height: 20,
                      //   thickness: 2,
                      //   indent: 20,
                      //   endIndent: 20,
                      // ),
                      //kvTile(), // Add the kvTile widget here
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
