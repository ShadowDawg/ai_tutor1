import 'package:ai_tutor1/backend/api_stuff.dart';
import 'package:ai_tutor1/colors.dart';
import 'package:ai_tutor1/models/chapter_info_model.dart';
import 'package:ai_tutor1/providers/data_provider.dart';
import 'package:ai_tutor1/providers/user_provider.dart';
import 'package:ai_tutor1/util_stuff/storage_utils.dart';
import 'package:ai_tutor1/views/lessons_page/lessons_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

// A mock function to simulate fetching chapter data.
// Replace with your actual data fetch logic.

class ChaptersPage extends StatefulWidget {
  final String subject;
  //final String grade = '5'; // TODO: FIX GETTING USER DETAILS! Provider?
  ChaptersPage({
    Key? key,
    required String subject,
    required String grade, // Take `subject` as a parameter
  })  : subject = subject
            .toLowerCase(), // Convert `subject` to lowercase and store it
        super(key: key);

  @override
  _ChaptersPageState createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  late Future<List<Chapter>> _chaptersFuture;
  late Future<Map<String, dynamic>> _completionFuture;
  late String grade; // Declare a variable to store the grade
  String? userId;
  bool _isDataFetched = false; // Add a new state variable

  final _storage = const FlutterSecureStorage(); // Initialize secure storage

  Future<List<Chapter>> fetchChapters(String grade, String subject) async {
    // Access the provider
    final chaptersProvider = Provider.of<dataProvider>(context, listen: false);

    // Check if the chapters are already cached
    var cachedChapters = chaptersProvider.getChapters(grade, subject);
    if (cachedChapters != null) {
      // Return the cached chapters
      return cachedChapters;
    }

    // If not cached, fetch from backend
    try {
      print("Fetching chapters from backend");
      List<Map<String, dynamic>> chapterData =
          await getChapterList(grade, subject);
      List<Chapter> chapters = chapterData.map((chapterMap) {
        Map<String, String> assIdMap = {};
        var assIdJson = chapterMap['assId'];
        if (assIdJson is Map) {
          assIdMap = Map<String, String>.from(assIdJson);
        }
        return Chapter(
          chapterMap['index'].toString(),
          chapterMap['name'],
          // assIdMap,
        );
      }).toList();

      // Cache the fetched chapters
      chaptersProvider.cacheChapters(grade, subject, chapters);

      return chapters;
    } catch (e) {
      print('Error fetching chapters: $e');
      throw Exception('Could not fetch chapters');
    }
  }

  @override
  void initState() {
    super.initState();
    _chaptersFuture = Future.value([]);
    _fetchUserIdAndData();
    // _chaptersFuture = fetchChapters(widget.grade, widget.subject);
    // grade =
    //     Provider.of<UserDataProvider>(context, listen: false).userData!.grade;
    // String userId =
    //     "P15eg77AELJb2ixeUle9"; // Placeholder for actual user ID fetch logic
    // _completionFuture =
    //     // fetchChapterCompletion(userId, widget.grade, widget.subject);
    //     fetchChapterCompletion(userId, '6', 'science');
  }

  Future<void> _fetchUserIdAndData() async {
    userId = await _storage.read(
        key: 'userToken'); // Fetch userId from secure storage
    if (userId == null) {
      // Handle the case where userId is not found
      print("User ID not found in secure storage");
      return;
    }
    if (mounted) {
      grade =
          Provider.of<UserDataProvider>(context, listen: false).userData!.grade;
    }
    _chaptersFuture = fetchChapters(grade, widget.subject.toLowerCase());
    _completionFuture =
        fetchChapterCompletion(userId!, grade, widget.subject.toLowerCase());
    //setState(() {}); // This triggers a rebuild with the fetched data
    setState(() {
      _isDataFetched = true; // Indicate that data has been fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDataFetched) {
      // Show a loading indicator or a placeholder until data is fetched
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        //title: Text('${widget.subject} Chapters'),
        foregroundColor: AppColors.brightGreen,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: FutureBuilder(
        future: Future.wait([_chaptersFuture, _completionFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No chapters found'));
          } else {
            List<Chapter> chapters = snapshot.data![0];
            Map<String, dynamic> completionDetails = snapshot.data![1];
            return ListView(
              children: <Widget>[
                // Big subject tile as part of ListView
                SubjectHeaderTile(
                  // imageUrl:
                  //     'https://cdn.britannica.com/87/2087-004-264616BB/Mona-Lisa-oil-wood-panel-Leonardo-da.jpg', // Replace with your image URL
                  backgroundImagePath:
                      'assets/images/backgrounds/${widget.subject.toLowerCase()}-tile.jpeg',
                  subjectName: widget.subject,
                  chapterCount: chapters
                      .length, // Assuming 'chapters' is the list of chapters
                ),
                // The rest of your ListView contents
                ...List<Widget>.generate(
                  chapters.length,
                  (index) {
                    Chapter chapter = chapters[index];
                    String completionStatus =
                        completionDetails[chapter.slNo] ?? "0";
                    return ChapterTile(
                      slNo: chapter.slNo,
                      name: chapter.name,
                      completionStatus: completionStatus,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonsPage(
                              grade: grade,
                              subject: widget.subject,
                              chapter: chapter,
                              currentLevel: int.parse(completionStatus),
                              //currentLevel: 1,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class SubjectHeaderTile extends StatelessWidget {
  final String backgroundImagePath;
  final String subjectName;
  final int chapterCount;

  const SubjectHeaderTile({
    Key? key,
    required this.backgroundImagePath,
    required this.subjectName,
    required this.chapterCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Getting the screen height
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      //height: 150, // Fixed height for the tile
      height: screenHeight * 0.22, // 20% of the screen height
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(34.0, 10.0, 34.0, 10.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor, // or any other color
        image: DecorationImage(
          image: AssetImage(backgroundImagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Image.network(
          //   imageUrl,
          //   width: 100, // Fixed width for the image
          //   height: 100, // Fixed height for the image
          //   fit: BoxFit.cover,
          // ),
          const SizedBox(width: 16), // Spacing between image and text
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit
                      .scaleDown, // Ensures the text scales down to fit the space
                  child: Text(
                    subjectName,
                    style: const TextStyle(
                      fontSize: 70, // Font size for the subject name
                      color: Colors.white, // Color for the subject name
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pixelify',
                    ),
                  ),
                ),
                Text(
                  '$chapterCount Chapters',
                  style: const TextStyle(
                    fontSize: 20, // Font size for the chapter count
                    color: Colors.white, // Color for the chapter count
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterTile extends StatelessWidget {
  final String slNo;
  final String name;
  final String completionStatus;
  final VoidCallback onTap;

  const ChapterTile({
    Key? key,
    required this.slNo,
    required this.name,
    required this.completionStatus,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: AppColors.tileColor,
        margin: const EdgeInsets.fromLTRB(34.0, 8.0, 34.0, 8.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slNo,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brightGreen,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: AppColors.brightGreen,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      completionStatus == "0"
                          ? "Not started"
                          : '$completionStatus/3 levels complete',
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                // Circular Progress Indicator
                child: CircularProgressIndicator(
                  value: completionPercentage(
                      (int.parse(completionStatus)).toString()),
                  //value: 1 / 3.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brightGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // double completionPercentage(String status) {
  //   // Convert completion status to a percentage value for the progress indicator
  //   // Assuming `completionStatus` is a string like "50%"
  //   return double.parse(status.replaceAll('%', '')) / 100;
  // }

  double completionPercentage(String status) {
    // Here you can convert the completion status to a percentage value
    // For example, if status is "50% Completed", you should return 0.5
    // This function is a placeholder, replace with actual logic
    String temp = status.replaceAll('% Completed', '');
    print(status);
    //print(double.tryParse(temp)! / 3.0);
    return (double.tryParse(status.replaceAll('% Completed', '')) ?? 0.0) / 3.0;
  }
}
