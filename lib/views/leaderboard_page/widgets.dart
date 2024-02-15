import 'package:ai_tutor1/colors.dart';
import 'package:ai_tutor1/imageAdresses.dart';
import 'package:ai_tutor1/misc_utils.dart';
import 'package:ai_tutor1/views/leaderboard_page/models.dart';
import 'package:flutter/material.dart';

class LeaderboardTitleCard extends StatelessWidget {
  final String username;
  final int streak;
  final int stars;

  const LeaderboardTitleCard({
    Key? key,
    required this.username,
    required this.streak,
    required this.stars,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220, // Adjust height as needed
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.tileColor, // Use your theme's color
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            username,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20), // Spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn("🔥 $streak", 'Streak'),
              _buildStatColumn("$stars", 'Stars'),
            ],
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
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 25,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class LeaderboardEntryCard extends StatelessWidget {
  final int rank;
  final String userName;
  final String userGender;
  final int stars;
  final int streak;

  const LeaderboardEntryCard({
    Key? key,
    required this.rank,
    required this.userName,
    required this.userGender,
    required this.stars,
    required this.streak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the card color based on the rank
    Color cardColor;
    Color textColor;
    switch (rank) {
      case 1:
        cardColor = Colors.amberAccent;
        textColor = Colors.black;
        break;
      case 2:
        cardColor = Colors.grey[300]!; // Silver-like color
        textColor = Colors.black;
        break;
      case 3:
        cardColor = Colors.brown[400]!; // Bronze-like color
        textColor = Colors.black;
        break;
      default:
        cardColor = AppColors.tileColor; // Default color for ranks below top 3
        textColor = Colors.white;
        break;
    }
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: AppColors.backgroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4.0),
            CircleAvatar(
              backgroundColor: cardColor,
              backgroundImage: AssetImage(
                userGender.toLowerCase() == 'male'
                    ? boyAvatar
                    : girlAvatar, // Choose the avatar based on gender
              ),
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(
                capitalize(userName),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 25,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '$stars',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 16.0),
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.red,
                  size: 25,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '$streak',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
