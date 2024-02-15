import 'package:ai_tutor1/providers/data_provider.dart';
import 'package:ai_tutor1/views/home_page/home_page.dart';
import 'package:ai_tutor1/views/home_with_nav/home_with_nav.dart';
import 'package:ai_tutor1/views/signup/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import './providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'colors.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Required for Firebase initialization

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (context) => dataProvider()),
        // Add other providers as needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = const FlutterSecureStorage();
  Widget _defaultHome = const SignupPage(); // Default to the signup page
  bool _isCheckingAuth = true; // To keep track of the ongoing check

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    // Check if 'userId' exists in secure storage
    String? userId = await storage.read(key: 'userToken');
    setState(() {
      if (userId != null) {
        // If token is found, set default home to Home Screen
        // CHANGE THIS
        _defaultHome = const HomeWithNavigationBar();
      }
      _isCheckingAuth = false; // Auth check is done
    });
  }

  @override
  Widget build(BuildContext context) {
    // While checking, show a loading indicator
    if (_isCheckingAuth) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Once check is complete, show the appropriate screen
    return MaterialApp(
      routes: {
        '/home': (context) => const LearningHomePage(),
      },
      title: 'AI Tutor App',
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _defaultHome,
    );
  }
}
