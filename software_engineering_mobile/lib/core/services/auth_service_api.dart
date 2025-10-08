import '../models/user.dart';
import '../repositories/shared_prefs_user_repository.dart';
import '../repositories/user_repository.dart' as repo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../api/api.dart';

class AuthService {
  static const String _activeUserKey = 'active_user_id';

  // Use the alias here
  final repo.UserRepository _userRepository;

  // Constructor
  AuthService({repo.UserRepository? userRepository})
      : _userRepository = userRepository ?? SharedPrefsUserRepository();

  /// Store the active user ID
  Future<void> setCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUserKey, userId);
  }

  /// Remove active user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeUserKey);
  }

  /// Get the active user ID
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeUserKey);
  }

  /// Get the currently logged-in User object
  Future<User?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;
    return await _userRepository.findById(userId); // use findById from repo.UserRepository
  }

  /// Login with email & password
  Future<User?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final String id = body['id']?.toString() ?? '';
        if (id.isEmpty) return null;
        await setCurrentUserId(id);
        return User(
          id: id,
          email: email,
          password: '',
          firstName: '',
          lastName: '',
          currency: 0,
          assets: const [],
          hippoBalanceCents: 0,
        );
      }
      return null;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
