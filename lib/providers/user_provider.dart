import 'package:ai_tutor1/models/user_data_model.dart';
import 'package:flutter/material.dart';

class UserDataProvider with ChangeNotifier {
  UserData? _userData;

  UserData? get userData => _userData;

  get streak => _userData!.streak;

  get stars => _userData!.stars;

  void setUserData(UserData userData) {
    _userData = userData;
    notifyListeners();
  }

  // Method to update stars and streak
  void updateStars(int newStars) {
    if (_userData != null) {
      // Update stars and streak within UserData
      _userData = UserData(
        name: _userData!.name,
        grade: _userData!.grade,
        section: _userData!.section,
        school: _userData!.school,
        admissionNumber: _userData!.admissionNumber,
        streak: _userData!.streak,
        stars: _userData!.stars + newStars,
        gender: _userData!.gender,
      );
      // Notify all listening widgets to rebuild
      notifyListeners();
    }
  }

  void updateStreak() {
    if (_userData != null) {
      // Update stars and streak within UserData
      _userData = UserData(
        name: _userData!.name,
        grade: _userData!.grade,
        section: _userData!.section,
        school: _userData!.school,
        admissionNumber: _userData!.admissionNumber,
        streak: _userData!.streak + 1,
        stars: _userData!.stars,
        gender: _userData!.gender,
      );
      // Notify all listening widgets to rebuild
      notifyListeners();
    }
  }
}
