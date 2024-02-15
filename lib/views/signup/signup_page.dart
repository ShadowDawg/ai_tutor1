import 'package:ai_tutor1/colors.dart';
import 'package:ai_tutor1/views/signup/signup_form.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SignupForm(),
      ),
    );
  }
}
