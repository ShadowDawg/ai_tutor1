import 'package:ai_tutor1/backend/api_stuff.dart';
import 'package:ai_tutor1/colors.dart';
import 'package:ai_tutor1/models/user_data_model.dart';
import 'package:ai_tutor1/providers/user_provider.dart';
import 'package:ai_tutor1/util_stuff/storage_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart'; // Assuming this is where your LeaderboardEntry model is defined
import 'widgets.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool isLoading = true;
  List<LeaderboardEntry> entries = [];
  UserData? userData;

  @override
  void initState() {
    super.initState();

    fetchLeaderboardEntries();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to access the Provider
    if (userData == null) {
      // To prevent fetching multiple times
      userData = Provider.of<UserDataProvider>(context, listen: false).userData;
      fetchLeaderboardEntries();
    }
  }

  Future<void> fetchLeaderboardEntries() async {
    setState(() {
      isLoading =
          true; // Assuming you have an isLoading flag to show a loading indicator
    });

    try {
      // Assuming you have a function to get the current user's details
      final userId = await getUserId(); // Fetch current user ID

      String grade = userData!.grade; // User's grade
      String school = userData!.school;
      String userName = userData!.name;
      String userGender = userData!.gender;
      // final userStats = await getUserstarsAndStreak(userId!);
      // final userstars = userStats['stars'];
      // final userStreak = userStats['streak'];
      int userStars = userData!.stars;
      int userStreak = userData!.streak;

      print(userId);
      print(grade);

      // Fetch leaderboard and user rank
      final result = await getLeaderboardAndUserRank(userId!, grade, school);
      print(result);
      final leaderboardData = result['leaderboard'] as List<dynamic>;
      final userRank = result['userRank'] as int; // Assuming userRank is an int

      // Convert the fetched data into a list of LeaderboardEntry objects
      final List<LeaderboardEntry> fetchedEntries =
          leaderboardData.map((entry) {
        return LeaderboardEntry(
          name: entry['name'],
          stars: entry['stars'],
          streak: entry['streak'],
          gender: entry['gender'],
          rank: leaderboardData.indexOf(entry) +
              1, // Rank based on position in the list
        );
      }).toList();

      if (userRank > 10) {
        // user not there in current list, append.
        fetchedEntries.add(LeaderboardEntry(
            name: userName,
            stars: userStars,
            streak: userStreak,
            gender: userGender,
            rank: userRank));
      }

      // Update the state with the new entries
      setState(() {
        entries = fetchedEntries;
        //currentUserRank = userRank; // Assuming you store the current user's rank separately
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching leaderboard entries: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      // Handle any errors here, such as showing a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            LeaderboardTitleCard(
              username: 'Leaderboard',
              stars: userData!.stars.toInt(),
              streak: userData!.streak.toInt(),
            ), // The custom widget for the title card
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  var entry = entries[index];
                  // Customize your ListTile or custom widget for each entry
                  return LeaderboardEntryCard(
                    rank: entry.rank,
                    userName: entry.name,
                    stars: entry.stars,
                    streak: entry.streak,
                    userGender: entry.gender,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simulate fetching data from the backend
  Future<List<LeaderboardEntry>> fetchFromBackend() async {
    // Replace this with your actual HTTP request logic
    await Future.delayed(const Duration(seconds: 2)); // Simulated network delay
    return [
      // Simulated data
      //LeaderboardEntry(name: "Alice", stars: 1200, streak: 5, rank: 1),
      // Add more entries...
    ];
  }
}
