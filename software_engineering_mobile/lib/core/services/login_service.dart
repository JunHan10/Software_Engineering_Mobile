import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class LoginService {
  /// Uses ApiService.login which already uses configured baseUrl and network checks
  static Future<User?> login(String email, String password) async {
    try {
      final data = await ApiService.login(email, password);
      if (data == null) return null;
      final user = User.fromJson(data);

      // Save user ID to local storage for session management
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('activeUserId', user.id!);

      return user;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
}
