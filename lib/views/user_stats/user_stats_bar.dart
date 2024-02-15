import 'package:flutter/material.dart';

class UserStatsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int streak;
  final int xp;
  final int gems;

  const UserStatsAppBar({
    Key? key,
    required this.title,
    required this.streak,
    required this.xp,
    required this.gems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        // Display user stats in the app bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department), // Icon for streak
              Text('$streak '),
              const Icon(Icons.star), // Icon for XP
              Text('$xp '),
              const Icon(Icons.diamond), // Icon for gems
              Text('$gems'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
