import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String?> getUserId() async {
  const storage = FlutterSecureStorage();
  try {
    // Assuming 'userToken' is the key you used to store the user ID
    String? userId = await storage.read(key: 'userToken');
    return userId;
  } catch (e) {
    print('Error reading user ID from secure storage: $e');
    return null;
  }
}
