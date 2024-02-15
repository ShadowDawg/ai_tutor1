import 'package:ai_tutor1/models/chapter_info_model.dart';
import 'package:flutter/material.dart';

class dataProvider with ChangeNotifier {
  // SUBJECT LIST FOR HOME PAGE
  List<String> _subjectList = [];
  List<String> get subjectList => _subjectList;
  set subjectList(List<String> newList) {
    _subjectList = newList;
    notifyListeners();
  }

  // CHAPTER LIST (by grade and subject) for Chapters Page.
  final Map<String, List<Chapter>> _cachedChapters = {};

  List<Chapter>? getChapters(String grade, String subject) {
    return _cachedChapters[_getCacheKey(grade, subject)];
  }

  void cacheChapters(String grade, String subject, List<Chapter> chapters) {
    _cachedChapters[_getCacheKey(grade, subject)] = chapters;
    notifyListeners();
  }

  String _getCacheKey(String grade, String subject) {
    return "$grade-$subject";
  }
}
