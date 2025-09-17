import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import 'user_repository.dart';

/**
 * LocalUserRepository - File-based repository using app documents directory.
 *
 * This repository reads initial seed data from assets/test_data.json (if needed),
 * caches in memory, and persists to a JSON file (test_data.json) under the app's
 * documents directory. It implements the UserRepository interface so it can be
 * swapped with alternative storage backends without touching UI code.
 */
class LocalUserRepository implements UserRepository {
  static const String _fileName = 'test_data.json';
  List<User>? _cachedUsers; // lazy-initialized in _loadUsers()

  // Utility: get the on-device file handle
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // Load all users: memory → disk → assets fallback
  Future<List<User>> _loadUsers() async {
    if (_cachedUsers != null) return _cachedUsers!;
    final file = await _getFile();
    if (await file.exists()) {
      final raw = await file.readAsString();
      final jsonData = json.decode(raw);
      _cachedUsers = (jsonData['users'] as List)
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList();
      return _cachedUsers!;
    }
    // Initialize from bundled assets if no file exists
    await _initializeFromAssets();
    return _cachedUsers ?? <User>[];
  }

  Future<void> _saveUsers(List<User> users) async {
    final file = await _getFile();
    final jsonData = json.encode({
      'users': users.map((u) => u.toJson()).toList(),
    });
    await file.writeAsString(jsonData);
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
    // Generate ID if null (simple local strategy)
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
      hippoBalanceCents: user.hippoBalanceCents, // keep incoming balance
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
    final user = users.firstWhere((u) => u.id == userId, orElse: () => User(
      id: userId,
      email: '',
      password: '',
      firstName: '',
      lastName: '',
      currency: 0.0,
      assets: const [],
      hippoBalanceCents: 0,
    ));
    return user.hippoBalanceCents;
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

  // Seed from assets/test_data.json if no local file exists yet
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

  // Simple local ID generator
  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}
