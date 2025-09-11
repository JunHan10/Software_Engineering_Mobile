// Dart core library for JSON encoding/decoding
import 'dart:convert';
// Flutter services for reading asset files
import 'package:flutter/services.dart';
// SharedPreferences for local key-value storage
import 'package:shared_preferences/shared_preferences.dart';
// Import User model and repository interface
import '../models/user.dart';
import 'user_repository.dart';

/**
 * SharedPrefsUserRepository - Concrete implementation of UserRepository using SharedPreferences
 *
 * This class implements the Repository pattern for user data storage using Flutter's
 * SharedPreferences, which provides persistent key-value storage on the device.
 *
 * Design goals:
 * - Keep API the same as LocalUserRepository so callers don't care about backend
 * - Cache users in memory for fewer JSON encode/decode cycles
 * - Initialize from assets/test_data.json on first run if no stored users exist
 */
class SharedPrefsUserRepository implements UserRepository {
  static const String _usersKey = 'users_v1'; // versioned key for migration
  List<User>? _cachedUsers; // in-memory cache

  // Load all users: memory → SharedPreferences → assets fallback
  Future<List<User>> _loadUsers() async {
    if (_cachedUsers != null) return _cachedUsers!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw != null) {
      final jsonData = json.decode(raw);
      _cachedUsers = (jsonData['users'] as List)
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList();
      return _cachedUsers!;
    }
    await _initializeFromAssets();
    return _cachedUsers ?? <User>[];
  }

  Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode({
      'users': users.map((u) => u.toJson()).toList(),
    });
    await prefs.setString(_usersKey, raw);
  }

  @override
  Future<User?> findByEmail(String email) async {
    final users = await _loadUsers();
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User?> findByEmailAndPassword(String email, String password) async {
    final users = await _loadUsers();
    try {
      return users.firstWhere((u) => u.email == email && u.password == password);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User> save(User user) async {
    final users = await _loadUsers();
    final id = user.id ?? _generateId();
    final idx = users.indexWhere((u) => u.id == id);
    final toSave = User(
      id: id,
      email: user.email,
      password: user.password,
      firstName: user.firstName,
      lastName: user.lastName,
      age: user.age,
      streetAddress: user.streetAddress,
      city: user.city,
      state: user.state,
      zipcode: user.zipcode,
      currency: user.currency,
      assets: user.assets,
      hippoBalanceCents: user.hippoBalanceCents, // preserve current balance
    );
    if (idx >= 0) {
      users[idx] = toSave;
    } else {
      users.add(toSave);
    }
    await _saveUsers(users);
    _cachedUsers = users;
    return toSave;
  }

  @override
  Future<void> delete(String id) async {
    final users = await _loadUsers();
    users.removeWhere((u) => u.id == id);
    await _saveUsers(users);
    _cachedUsers = users;
  }

  // NEW: Hippopotamoney helpers ---------------------------------------------
  @override
  Future<int> getHippoBalanceCents(String userId) async {
    final users = await _loadUsers();
    final u = users.firstWhere(
          (u) => u.id == userId,
      orElse: () => User(
        id: userId,
        email: '',
        password: '',
        firstName: '',
        lastName: '',
        currency: 0.0,
        assets: const [],
        hippoBalanceCents: 0,
      ),
    );
    return u.hippoBalanceCents;
  }

  @override
  Future<void> setHippoBalanceCents(String userId, int newBalanceCents) async {
    final users = await _loadUsers();
    final idx = users.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    users[idx] = users[idx].copyWith(hippoBalanceCents: newBalanceCents);
    await _saveUsers(users);
    _cachedUsers = users;
  }

  @override
  Future<int> depositHippoCents(String userId, int amountCents) async {
    final current = await getHippoBalanceCents(userId);
    final next = current + amountCents;
    await setHippoBalanceCents(userId, next);
    return next;
  }

  @override
  Future<int> withdrawHippoCents(String userId, int amountCents) async {
    final current = await getHippoBalanceCents(userId);
    final next = current - amountCents;
    await setHippoBalanceCents(userId, next < 0 ? 0 : next);
    return next < 0 ? 0 : next;
  }

  // Initialize from bundled assets on first run (if nothing in SharedPreferences)
  Future<void> _initializeFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString('assets/test_data.json');
      final jsonData = json.decode(jsonString);
      _cachedUsers = (jsonData['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();
      await _saveUsers(_cachedUsers!);
    } catch (e) {
      _cachedUsers = [];
    }
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  /**
   * Developer utility (optional):
   * Clear all saved data to reset to the asset seed.
   * WARNING: destructive in production!
   */
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    _cachedUsers = null;
    print('All SharedPreferences data cleared!');
  }

  // DEBUG UTILITY: print all users to console (development only)
  Future<void> printAllUsers() async {
    final users = await _loadUsers();
    for (final u in users) {
      // keep it simple; printing JSON helps verify serialization
      print(json.encode(u.toJson()));
    }
  }
}
