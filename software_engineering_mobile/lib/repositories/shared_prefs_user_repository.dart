import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'user_repository.dart';

class SharedPrefsUserRepository implements UserRepository {
  static const String _usersKey = 'users_data';
  List<User>? _cachedUsers;

  @override
  Future<User?> findByEmail(String email) async {
    final users = await _loadUsers();
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User?> findByEmailAndPassword(String email, String password) async {
    final users = await _loadUsers();
    try {
      return users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> save(User user) async {
    final users = await _loadUsers();
    
    // Generate ID if new user
    final newUser = user.id == null 
        ? User(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
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
          )
        : user;
    
    // Add or update user
    final existingIndex = users.indexWhere((u) => u.id == newUser.id);
    if (existingIndex >= 0) {
      users[existingIndex] = newUser;
    } else {
      users.add(newUser);
    }
    
    await _saveUsers(users);
    _cachedUsers = users;
    
    return newUser;
  }

  @override
  Future<void> delete(String id) async {
    final users = await _loadUsers();
    users.removeWhere((user) => user.id == id);
    await _saveUsers(users);
    _cachedUsers = users;
  }

  Future<List<User>> _loadUsers() async {
    if (_cachedUsers != null) return _cachedUsers!;

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson != null) {
      // Load from shared preferences
      final jsonData = json.decode(usersJson);
      _cachedUsers = (jsonData['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();
    } else {
      // Initialize from assets/test_data.json
      await _initializeFromAssets();
    }
    
    return _cachedUsers ?? [];
  }

  Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = {
      'users': users.map((user) => user.toJson()).toList(),
    };
    await prefs.setString(_usersKey, json.encode(jsonData));
  }

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

  // Debug method to print all users
  Future<void> printAllUsers() async {
    final users = await _loadUsers();
    print('=== ALL STORED USERS ===');
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      print('User ${i + 1}:');
      print('  ID: ${user.id}');
      print('  Email: ${user.email}');
      print('  Password: ${user.password}');
      print('  Name: ${user.firstName} ${user.lastName}');
      print('  Age: ${user.age ?? "Not provided"}');
      print('  Address: ${user.streetAddress ?? ""}, ${user.city ?? ""}, ${user.state ?? ""} ${user.zipcode ?? ""}');
      print('  Currency: \$${user.currency}');
      print('  Assets: ${user.assets.length} items');
      for (var asset in user.assets) {
        print('    - ${asset.name}: \$${asset.value}');
      }
      print('---');
    }
    print('=== END OF USERS ===');
  }

  // Method to clear all stored data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    _cachedUsers = null;
    print('All SharedPreferences data cleared!');
  }
}