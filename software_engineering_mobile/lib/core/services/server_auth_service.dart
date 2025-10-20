import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class ServerAuthService {
  static const String _activeUserKey = 'activeUserId';

  static Future<User?> login(String email, String password) async {
    final userData = await ApiService.login(email, password);
    if (userData != null) {
      final user = User.fromJson(userData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeUserKey, user.id!);
      return user;
    }
    return null;
  }

  static Future<User?> register(Map<String, dynamic> userData) async {
    final serverUser = await ApiService.createUser(userData);
    if (serverUser != null) {
      final user = User.fromJson(serverUser);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeUserKey, user.id!);
      return user;
    }
    return null;
  }

  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeUserKey);
  }

  static Future<User?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;
    final userData = await ApiService.getUserById(userId);
    return userData != null ? User.fromJson(userData) : null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeUserKey);
  }
}