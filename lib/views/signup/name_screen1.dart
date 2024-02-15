import 'package:ai_tutor1/models/signup_data_model.dart';
import 'package:flutter/material.dart';

class NameScreen extends StatelessWidget {
  final SignupData signupData;
  final VoidCallback onContinue;

  const NameScreen(
      {Key? key, required this.signupData, required this.onContinue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => signupData.name = value,
          decoration: const InputDecoration(labelText: 'What\'s your name?'),
        ),
        ElevatedButton(onPressed: onContinue, child: const Text('Continue')),
        // Other widgets...
      ],
    );
  }
}
