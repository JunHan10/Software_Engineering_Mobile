// Dart core library for JSON encoding/decoding
import 'dart:convert';

// Flutter services for reading bundled assets (first-run seed data)
import 'package:flutter/services.dart' show rootBundle;

// SharedPreferences for local key-value storage
import 'package:shared_preferences/shared_preferences.dart';

// App models & repo interface
import '../models/user.dart';
import 'user_repository.dart';

/**
 * SharedPrefsUserRepository - Concrete implementation of UserRepository using SharedPreferences
 *
 * Initializes from assets/test_data.json on first run.
 * Stores all users under a single versioned key as a JSON string:
 *   { "users": [ {user1}, {user2}, ... ] }
 *
 * Caches users in-memory to minimize decode/encode operations and disk reads.
 */
class SharedPrefsUserRepository implements UserRepository {
  /// Versioned key (easier future migrations)
  static const String _usersKey = 'users_data';

  /// In-memory cache of users (null => not loaded yet)
  List<User>? _cachedUsers;

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Load all users from memory, SharedPreferences, or seed from assets.
  Future<List<User>> _loadUsers() async {
    if (_cachedUsers != null) return _cachedUsers!;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);

    if (raw != null) {
      try {
        final map = json.decode(raw) as Map<String, dynamic>;
        final list = (map['users'] as List? ?? const <dynamic>[])
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
        _cachedUsers = list;
        return list;
      } catch (_) {
        // If decode fails for any reason, fall back to seed
      }
    }

    await _initializeFromAssets();
    return _cachedUsers ?? <User>[];
  }

  /// Persist users list to SharedPreferences and keep cache in sync.
  Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode({
      'users': users.map((u) => u.toJson()).toList(),
    });
    await prefs.setString(_usersKey, raw);
    _cachedUsers = users;
  }

  /// First-run: seed from bundled assets/test_data.json if nothing stored.
  Future<void> _initializeFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString('assets/test_data.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final users = (jsonData['users'] as List? ?? const <dynamic>[])
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList();
      _cachedUsers = users;
      await _saveUsers(users);
    } catch (_) {
      _cachedUsers = <User>[];
      await _saveUsers(_cachedUsers!);
    }
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ---------------------------------------------------------------------------
  // UserRepository core methods
  // ---------------------------------------------------------------------------

  /// Find by email only (registration checks, etc.)
  @override
  Future<User?> findByEmail(String email) async {
    final users = await _loadUsers();
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  /// Find by email + password (login)
  @override
  Future<User?> findByEmailAndPassword(String email, String password) async {
    final users = await _loadUsers();
    try {
      return users.firstWhere((u) => u.email == email && u.password == password);
    } catch (_) {
      return null;
    }
  }

  /// Upsert a user (create if new id, update if existing)
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
      hippoBalanceCents: user.hippoBalanceCents, // preserve HB
    );

    if (idx >= 0) {
      users[idx] = toSave;
    } else {
      users.add(toSave);
    }

    await _saveUsers(users);
    return toSave;
  }

  /// Delete a user by id
  @override
  Future<void> delete(String id) async {
    final users = await _loadUsers();
    users.removeWhere((u) => u.id == id);
    await _saveUsers(users);
  }

  // ---------------------------------------------------------------------------
  // Hippo Bucks (HB) methods (required by UserRepository)
  // Stored as integer cents to avoid floating point issues.
  // ---------------------------------------------------------------------------

  @override
  Future<int> getHippoBalanceCents(String userId) async {
    final users = await _loadUsers();
    try {
      final u = users.firstWhere((u) => u.id == userId);
      return u.hippoBalanceCents;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> setHippoBalanceCents(String userId, int newBalanceCents) async {
    final users = await _loadUsers();
    final idx = users.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    users[idx] = users[idx].copyWith(hippoBalanceCents: newBalanceCents);
    await _saveUsers(users);
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
    var next = current - amountCents;
    if (next < 0) next = 0;
    await setHippoBalanceCents(userId, next);
    return next;
  }

  // ---------------------------------------------------------------------------
  // Dev utilities (optional)
  // ---------------------------------------------------------------------------

  /// Clear all saved data (reseeds from assets on next load)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    _cachedUsers = null;
    // Note: next call to _loadUsers will reseed from assets.
    print('All SharedPreferences data cleared.'); // debug print
  }

  /// Print each user as JSON in console (helps during development)
  Future<void> printAllUsers() async {
    final users = await _loadUsers();
    for (final u in users) {
      // ignore: avoid_print
      print(json.encode(u.toJson()));
    }
  }
}
