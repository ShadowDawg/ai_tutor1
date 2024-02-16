import 'package:ai_tutor1/colors.dart';
import 'package:ai_tutor1/imageAdresses.dart';
import 'package:ai_tutor1/misc_utils.dart';
import 'package:flutter/material.dart';

class TitleBox extends StatelessWidget {
  final String title;
  const TitleBox({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Or any color that fits your design
        ),
      ),
    );
  }
}

class ContinueLearningCard extends StatelessWidget {
  final bool hasLastLessonData;
  final VoidCallback onContinue;
  final VoidCallback onStartNew;

  const ContinueLearningCard({
    Key? key,
    required this.hasLastLessonData,
    required this.onContinue,
    required this.onStartNew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasLastLessonData ? onContinue : onStartNew,
      child: Container(
        height: 100,
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.purple, // Assuming you have a class for colors
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            hasLastLessonData
                ? 'Pick up where you left off!'
                : 'Start learning now!',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class UserStatsCard extends StatelessWidget {
  final String username;
  final int streak;
  final int stars;
  final String avatarUrl; // Add a parameter for avatar URL

  const UserStatsCard({
    Key? key,
    required this.username,
    required this.streak,
    required this.stars,
    required this.avatarUrl, // Initialize the avatar URL
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 240, // Adjust height as needed
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.tileColor, // Use your theme's color
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start, // Align to left
              children: [
                Text(
                  capitalize(username),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pixelify',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20), // Spacing

                _buildStatColumn("⭐ $stars", 'Stars'),
                const SizedBox(height: 10), // Spacing for better layout
                _buildStatColumn("🔥 $streak", 'Streak'),
              ],
            ),
          ),
          // CircleAvatar(
          //   radius: 100, // Adjust the size as needed
          //   backgroundColor: AppColors.tileColor,
          //   backgroundImage: NetworkImage(avatarUrl), // Load avatar image
          // ),
          Container(
            width: 165, // Width of the rectangular avatar
            height:
                200, // Height of the rectangular avatar, making it rectangular
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  avatarUrl,
                ), // Use local asset
                fit: BoxFit.cover, // Cover the container bounds
              ),
              borderRadius: BorderRadius.circular(
                  8), // Optional: if you want rounded corners
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            //fontFamily: 'Pixelify',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 26,
            color: Colors.white70,
            fontFamily: 'Pixelify',
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String imageUrl;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.onTap,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color titleColor = Colors.white; // Default color

    // Set text color based on the title
    if (title.toLowerCase() == 'science' || title.toLowerCase() == 'civics') {
      titleColor = Colors.white;
    } else if (title.toLowerCase() == 'history') {
      titleColor = Colors.black;
    }

    return Material(
      // Wrap with Material
      color: Colors.transparent, // Avoid any unwanted background color
      child: InkWell(
        // Use InkWell for tap feedback
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20.0), // Match the container's border radius
        child: AnimatedContainer(
          // Use AnimatedContainer for animations
          duration: const Duration(milliseconds: 20), // Animation duration
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.tileColor,
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/backgrounds/${title.toLowerCase()}-tile.jpeg'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40, // Increase the font size for bigger letters
                fontWeight: FontWeight.bold,
                fontFamily: 'Pixelify',
                color: titleColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class kvTile extends StatelessWidget {
  // You can hardcode the title and image URL or pass them as parameters if needed
  final String title =
      "Built with ❤️ for Students of KV by Students of IITM."; // Example fixed title
  final String imageUrl = leaderboardBG; // Example fixed background image path

  kvTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Avoid any unwanted background color
      child: InkWell(
        onTap: () {
          // Define what happens when the tile is tapped
          print("kvTile tapped!");
        },
        borderRadius:
            BorderRadius.circular(20.0), // Match the container's border radius
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), // Animation duration
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.tileColor, // Use your theme's color for the tile
            image: DecorationImage(
              image: AssetImage(kvImage), // Use the fixed background image
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30, // Font size for the title
                fontWeight: FontWeight.bold,
                //fontFamily: 'Pixelify',
                color: Colors.black, // Color for the title
              ),
            ),
          ),
        ),
      ),
    );
  }
}



// class CategoryCard extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;
//   final String imageUrl;

//   const CategoryCard({
//     Key? key,
//     required this.title,
//     required this.onTap,
//     required this.imageUrl,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Color titleColor = Colors.white; // Default color

//     // Set text color based on the title
//     if (title.toLowerCase() == 'science' || title.toLowerCase() == 'civics') {
//       titleColor = Colors.white;
//     } else if (title.toLowerCase() == 'history') {
//       titleColor = Colors.black;
//     }

//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200), // Animation duration,
//         margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           // color: Colors.white,
//           color: AppColors.tileColor,
//           image: DecorationImage(
//               image: AssetImage(
//                   'assets/images/backgrounds/${title.toLowerCase()}-tile.jpeg'),
//               fit: BoxFit.cover),
//           borderRadius: BorderRadius.circular(20.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               spreadRadius: 2,
//               blurRadius: 6,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 40, // Increase the font size for bigger letters
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Pixelify',
//               color: titleColor,
//               //color: AppColors.
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
