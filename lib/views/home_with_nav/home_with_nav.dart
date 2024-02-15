import 'package:ai_tutor1/colors.dart';
import 'package:ai_tutor1/views/home_page/home_page.dart';
import 'package:ai_tutor1/views/leaderboard_page/leaderboard_page.dart';
import 'package:flutter/material.dart';

class HomeWithNavigationBar extends StatefulWidget {
  const HomeWithNavigationBar({Key? key}) : super(key: key);

  @override
  _HomeWithNavigationBarState createState() => _HomeWithNavigationBarState();
}

class _HomeWithNavigationBarState extends State<HomeWithNavigationBar> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const LearningHomePage(),
    const LeaderboardPage(),

    // Add more pages as needed
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          // Add more destinations as needed
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: AppColors.darkPurple,
        indicatorColor: AppColors.brightGreen,
        // Customize other properties as needed
      ),
    );
  }
}
