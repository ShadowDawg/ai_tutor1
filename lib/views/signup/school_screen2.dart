import 'package:ai_tutor1/models/signup_data_model.dart';
import 'package:flutter/material.dart';

class SchoolScreen extends StatelessWidget {
  final SignupData signupData;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const SchoolScreen(
      {Key? key,
      required this.signupData,
      required this.onContinue,
      required this.onBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => signupData.school = value,
          decoration:
              const InputDecoration(labelText: 'Which school are you from?'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(onPressed: onBack, child: const Text('Back')),
            ElevatedButton(
                onPressed: onContinue, child: const Text('Continue')),
          ],
        ),
        // Other widgets...
      ],
    );
  }
}
