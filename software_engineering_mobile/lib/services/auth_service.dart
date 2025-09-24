// lib/services/auth_service.dart
//
// Central place to manage "who is logged in" for the app.
// - We authenticate using SharedPrefsUserRepository (local JSON in SharedPreferences).
// - The active userId is stored in SharedPreferences under 'activeUserId'.
// - Other screens (Dashboard/Profile/Active Loans) can read that id.

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../repositories/shared_prefs_user_repository.dart';

class AuthService {
  static const _activeUserKey = 'activeUserId';
  final _repo = SharedPrefsUserRepository();

  /// Attempt to log in with email + password.
  /// Returns the User on success, or null if credentials are invalid.
  Future<User?> loginWithEmailPassword(String email, String password) async {
    final user = await _repo.findByEmailAndPassword(email, password);
    if (user != null && user.id != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeUserKey, user.id!);
    }
    return user;
  }

  /// Clear session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeUserKey);
  }

  /// Returns the active user id if someone is logged in, else null.
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeUserKey);
  }

  /// Convenience: fetch the full active User (or null)
  Future<User?> getCurrentUser() async {
    final id = await getCurrentUserId();
    if (id == null) return null;
    return _repo.findById(id);
  }
}
