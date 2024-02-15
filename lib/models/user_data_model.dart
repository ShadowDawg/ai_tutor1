// USERID is not stored in PROVIDER, only in flutter_secure_storage.
class UserData {
  String name;
  String school;
  String grade;
  String section;
  String admissionNumber;
  String gender;
  int streak;
  int stars;

  UserData({
    required this.name,
    required this.school,
    required this.grade,
    required this.section,
    required this.admissionNumber,
    required this.gender,
    required this.streak, // Default values bruv
    required this.stars,
  });
  // Add methods as needed, e.g., fromMap(), toMap() for Firestore integration
}
