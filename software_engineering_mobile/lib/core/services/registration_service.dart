import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class RegistrationService {
  static Future<User?> register(Map<String, dynamic> userData) async {
    try {
      final data = await ApiService.createUser(userData);
      if (data == null) return null;
      final user = User.fromJson(data);

      // Save user ID to local storage for session management
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('activeUserId', user.id!);

      return user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }
}
