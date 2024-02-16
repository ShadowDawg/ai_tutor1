import 'package:ai_tutor1/colors.dart';
import 'package:ai_tutor1/imageAdresses.dart';
import 'package:ai_tutor1/models/chapter_info_model.dart';
import 'package:ai_tutor1/views/subject_pages/chat_page/chat_page.dart';
import 'package:flutter/material.dart';

class LessonsPage extends StatelessWidget {
  final String grade;
  final String subject;
  final Chapter chapter;
  final int currentLevel;

  const LessonsPage({
    Key? key,
    required this.grade,
    required this.subject,
    required this.chapter,
    required this.currentLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        foregroundColor: AppColors.brightGreen,
        title: Text('Levels for ${chapter.name}'),
      ),
      body: Column(
        children: [
          const LevelsHeaderWidget(), // Include the header widget here
          Expanded(
            child: Center(
              // Use Center to horizontally center the Row
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Evenly space out the tiles
                children: List.generate(3, (index) {
                  // Generate 3 LessonTiles
                  bool isLessonAccessible = (index + 1) <= currentLevel + 1;
                  bool isLessonComplete = (index + 1) <= currentLevel;

                  return LessonTile(
                    isAccessible: isLessonAccessible,
                    isComplete: isLessonComplete,
                    onTap: () {
                      if (isLessonAccessible) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                                grade: grade,
                                subject: subject,
                                chapterName: chapter.name,
                                chapterNumber: chapter.slNo.toString(),
                                levelNumber: (index + 1).toString()),
                          ),
                        );
                      }
                    },
                    levelNumber: (index + 1),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LevelsHeaderWidget extends StatelessWidget {
  const LevelsHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtain screen size for responsive layout
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.60, // 20% of the screen height
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: AppColors.tileColor, // Adjust the background color as needed
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            //image: AssetImage('assets/images/backgrounds/levelHeader.jpeg'),
            image: AssetImage(levelHeaderKV),
            fit: BoxFit.cover,
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const FittedBox(
            fit: BoxFit
                .scaleDown, // Ensures the text scales down to fit the space
            child: Text(
              'Choose your Level',
              style: TextStyle(
                fontSize: 30,
                //fontWeight: FontWeight.bold,
                fontFamily: 'Pixelify',

                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete the previous levels to progress.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class LessonTile extends StatelessWidget {
  final int levelNumber;
  final bool isAccessible;
  final bool isComplete;
  final VoidCallback? onTap;

  const LessonTile({
    Key? key,
    required this.levelNumber,
    required this.isAccessible,
    required this.isComplete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Margins and paddings
    double horizontalMargin = 16.0; // Margin on each side of the row
    double spacingBetweenTiles = 16.0; // Spacing between the tiles

    // Calculate the diameter based on the screen width
    // Subtract the margins and the spacings, then divide by the number of tiles per row
    double tileDiameter =
        (screenWidth - (horizontalMargin * 2) - (spacingBetweenTiles * 2)) / 3;

    Color buttonColor = AppColors.tileColor;
    if (isComplete) {
      buttonColor = AppColors.brightGreen;
    } else if (isAccessible) {
      buttonColor = Colors.amber;
    }

    IconData iconData = Icons.lock; // Default icon
    if (isComplete) {
      iconData = Icons.check; // Icon for completed
    } else if (isAccessible) {
      iconData = Icons.play_arrow; // Icon for accessible but not completed
    }

    return GestureDetector(
      onTap: isAccessible ? onTap : null,
      child: Container(
        width: tileDiameter,
        height: tileDiameter,
        decoration: BoxDecoration(
          color: buttonColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$levelNumber",
              style: const TextStyle(
                fontSize: 30.0, // Adjust based on your design needs
                fontWeight: FontWeight.bold,
                fontFamily: 'Pixelify',
                color: Colors.white,
              ),
            ),
            Icon(
              iconData,
              color: Colors.white,
              size: tileDiameter / 2.5, // Adjust the icon size as needed
            ),
          ],
        ),
      ),
    );
  }
}


// class LessonTile extends StatelessWidget {
//   // final String title;
//   final bool isAccessible;
//   final bool isComplete;
//   final VoidCallback? onTap;
//   // final String grade;
//   // final String subject;
//   // final String chapterName;
//   // final String chapterNumber;
//   final String levelNumber;

//   const LessonTile({
//     Key? key,
//     // required this.title,
//     required this.isAccessible,
//     required this.isComplete,
//     this.onTap,
//     // required this.grade,
//     // required this.subject,
//     // required this.chapterName,
//     // required this.chapterNumber,
//     required this.levelNumber,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Circular tile dimensions
//     double size = 80.0; // Diameter of the circle

//     return GestureDetector(
//       onTap: isAccessible ? onTap : null,
//       child: Container(
//         margin: const EdgeInsets.all(16.0),
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//         decoration: BoxDecoration(
//           // color: isAccessible ? Colors.white : Colors.grey[300],
//           color: isAccessible ? Colors.amber : AppColors.tileColor,
//           borderRadius: BorderRadius.circular(10.0),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 levelNumber,
//                 style: TextStyle(
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.bold,
//                   color: isAccessible ? Colors.black : Colors.grey,
//                 ),
//               ),
//             ),
//             Icon(
//               isComplete
//                   ? Icons.check // Icon for complete
//                   : isAccessible
//                       ? Icons
//                           .arrow_forward // Icon for accessible but not complete
//                       : Icons.lock, // Icon for not accessible
//               color: isComplete || isAccessible
//                   ? Theme.of(context).primaryColor
//                   : Colors.grey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
