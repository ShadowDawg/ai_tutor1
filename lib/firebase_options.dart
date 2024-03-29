// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAPMLPBSL9WkFCeYvpCPrzKCSBz3de66jc',
    appId: '1:1094830314194:web:8536ab70fd89a66a60930b',
    messagingSenderId: '1094830314194',
    projectId: 'ai-tutor1',
    authDomain: 'ai-tutor1.firebaseapp.com',
    storageBucket: 'ai-tutor1.appspot.com',
    measurementId: 'G-CM0ZYKJEVH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9VO7frvVXPgdQ6E_iYzABHm8cj3qLEMc',
    appId: '1:1094830314194:android:2ce63ca99c177f5660930b',
    messagingSenderId: '1094830314194',
    projectId: 'ai-tutor1',
    storageBucket: 'ai-tutor1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBkNxvZ6G4hsvThXpGoKS1LAfGxBoEo9pw',
    appId: '1:1094830314194:ios:be5981ffbc9e515360930b',
    messagingSenderId: '1094830314194',
    projectId: 'ai-tutor1',
    storageBucket: 'ai-tutor1.appspot.com',
    iosBundleId: 'com.example.aiTutor1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBkNxvZ6G4hsvThXpGoKS1LAfGxBoEo9pw',
    appId: '1:1094830314194:ios:ab0c2e853c416ee460930b',
    messagingSenderId: '1094830314194',
    projectId: 'ai-tutor1',
    storageBucket: 'ai-tutor1.appspot.com',
    iosBundleId: 'com.example.aiTutor1.RunnerTests',
  );
}
