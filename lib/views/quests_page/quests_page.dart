import 'package:flutter/material.dart';

class QuestsPage extends StatelessWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quests")),
      body: const Center(child: Text("Quests Page")),
    );
  }
}

// Similar for LeaderboardPage and ProfilePage...
