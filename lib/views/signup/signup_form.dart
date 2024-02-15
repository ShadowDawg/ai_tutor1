// ignore_for_file: avoid_print

import 'package:ai_tutor1/colors.dart';
import 'package:ai_tutor1/imageAdresses.dart';
import 'package:ai_tutor1/models/signup_data_model.dart';
import 'package:ai_tutor1/providers/user_provider.dart';
import 'package:ai_tutor1/views/home_page/home_page.dart';
import 'package:ai_tutor1/views/home_with_nav/home_with_nav.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

String changeToLower(String text) {
  return text.toLowerCase();
}

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final SignupData _signupData = SignupData();

  final List<int> _classOptions = [5, 6, 7];
  int? _selectedClass;
  final List<String> _schoolOptions = ['KV IIT Madras']; // List of schools
  String? _selectedSchool;
  final _storage = const FlutterSecureStorage();
  // Add gender options and a variable to hold the selected gender
  final List<String> _genderOptions = ['male', 'female'];
  String? _selectedGender;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // TODO: If a document with same school and adm no. already exists in fb => pre-existing user
      // don't push obtained details. just get id of that doc on fb.

      // Define a reference to the Firestore collection where users are stored
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      try {
        final querySnapshot = await users
            .where('school', isEqualTo: changeToLower(_signupData.school ?? ''))
            .where('admissionNumber',
                isEqualTo: changeToLower(_signupData.admissionNumber ?? ''))
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // User already exists
          print('User already exists');

          // Get the existing user's ID
          String userId = querySnapshot.docs.first.id;

          // Store the user ID in secure storage
          await _storage.write(key: 'userToken', value: userId);

          // Navigate to the Home Page if the widget is still mounted
          if (!mounted) return;
          // Fetch user data from Firestore and update it in the provider
          // await Provider.of<UserProvider>(context, listen: false)
          //     .fetchUserFromFirestore(userId);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const HomeWithNavigationBar()),
          );
        } else {
          // Add a new document with the user data
          // TODO: Handle in nodejs
          DocumentReference docRef = await users.add({
            'name': changeToLower(_signupData.name ?? ''),
            //'email': changeToLower(_signupData.email ?? ''), // Uncomment if email should be changeToLowerd
            'school': changeToLower(_signupData.school ?? ''),
            'class': _signupData
                .classNumber, // Assuming class is a number, no capitalization needed
            'section': changeToLower(_signupData.section ?? ''),
            'admissionNumber': changeToLower(_signupData.admissionNumber ?? ''),
            'stars': 0,
            'streak': 0,
            'gender':
                changeToLower(_selectedGender ?? 'male'), // Add the gender
          });
          print('User added to Firestore');
          // Get the newly created user's ID
          String userId = docRef.id;
          // Store the user ID in secure storage
          await _storage.write(key: 'userToken', value: userId);
          // Handle navigation or UI response here
          // Check if the widget is still in the widget tree
          // Navigate to the Home Page if the widget is still mounted
          if (!mounted) return;
          // Fetch user data from Firestore and update it in the provider

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const HomeWithNavigationBar()),
          );
        }
      } catch (e) {
        print('Error adding user to Firestore: $e');
        // Handle error

        if (!mounted) return;
        // Handle error UI update if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.near_me,
                      color: AppColors.brightGreen,
                    ),
                    labelText: 'Name',
                    fillColor: AppColors.tileColor,
                    filled: true,
                    labelStyle: TextStyle(
                      color: AppColors.brightGreen,
                      fontSize: 20,
                    ),
                    // Border when TextFormField is not in focus
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.lightGreenAccent,
                      ), // Change this color to change the underline color
                    ),
                    // Border when TextFormField is in focus
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brightGreen,
                      ), // Change this color for focused underline color
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.brightBlue,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                  onSaved: (value) => _signupData.name = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'School',
                    fillColor: AppColors.tileColor,
                    filled: true,
                    labelStyle: TextStyle(
                      color: AppColors.brightGreen,
                      fontSize: 20,
                    ),
                    // Border when TextFormField is not in focus
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.lightGreenAccent,
                      ), // Change this color to change the underline color
                    ),
                    // Border when TextFormField is in focus
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brightGreen,
                      ), // Change this color for focused underline color
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.brightBlue,
                  ),
                  value: _selectedSchool,
                  items: _schoolOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedSchool = newValue),
                  onSaved: (value) => _signupData.school = value,
                  validator: (value) =>
                      value == null ? 'Please select your school' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    fillColor: AppColors.tileColor,
                    filled: true,
                    labelStyle: TextStyle(
                      color: AppColors.brightGreen,
                      fontSize: 20,
                    ),
                    // Border when TextFormField is not in focus
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.lightGreenAccent,
                      ), // Change this color to change the underline color
                    ),
                    // Border when TextFormField is in focus
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brightGreen,
                      ), // Change this color for focused underline color
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.brightBlue,
                  ),
                  value: _selectedClass,
                  items: _classOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedClass = newValue),
                  onSaved: (value) => _signupData.classNumber = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Section',
                    fillColor: AppColors.tileColor,
                    filled: true,
                    labelStyle: TextStyle(
                      color: AppColors.brightGreen,
                      fontSize: 20,
                    ),
                    // Border when TextFormField is not in focus
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.lightGreenAccent,
                      ), // Change this color to change the underline color
                    ),
                    // Border when TextFormField is in focus
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brightGreen,
                      ), // Change this color for focused underline color
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.brightBlue,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your section' : null,
                  onSaved: (value) => _signupData.section = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextFormField(
                  style: const TextStyle(
                    color: AppColors.brightBlue,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Admission Number',
                    fillColor: AppColors.tileColor,
                    filled: true,
                    labelStyle: TextStyle(
                      color: AppColors.brightGreen,
                      fontSize: 20,
                    ),
                    // Border when TextFormField is not in focus
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.lightGreenAccent,
                      ), // Change this color to change the underline color
                    ),
                    // Border when TextFormField is in focus
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brightGreen,
                      ), // Change this color for focused underline color
                    ),
                  ),
                  validator: (value) => value!.isEmpty
                      ? 'Please enter your admission number'
                      : null,
                  onSaved: (value) => _signupData.admissionNumber = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                // Dropdown for selecting gender
                child: DropdownButtonFormField<String>(
                  style: const TextStyle(
                    color: AppColors.brightBlue,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    fillColor: AppColors.tileColor,
                    filled: true,
                    labelStyle: TextStyle(
                      color: AppColors.brightGreen,
                      fontSize: 20,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreenAccent),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.brightGreen),
                    ),
                  ),
                  value: _selectedGender,
                  items: _genderOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedGender = newValue),
                  validator: (value) =>
                      value == null ? 'Please select your gender' : null,
                ),
              ),
              // Expanded widget to use the remaining vertical space

              Column(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Space out vertically
                  children: [
                    // Insert your last entry field here...

                    // Row for the pictures
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround, // Space out images
                      children: [
                        Expanded(
                          child: Image(
                            image: AssetImage(boyFull),
                            fit: BoxFit.fill,
                          ),
                        ),
                        Expanded(
                          child: Image(
                            image: AssetImage(girlFull),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Sign Up'),
                    ),
                    // Add space at the bottom to ensure content is visible above the keyboard
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
