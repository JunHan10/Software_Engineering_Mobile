import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import 'user_repository.dart';

class LocalUserRepository implements UserRepository {
  static const String _fileName = 'test_data.json';
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

    try {
      final file = await _getUsersFile();
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = json.decode(jsonString);
        _cachedUsers = (jsonData['users'] as List)
            .map((userJson) => User.fromJson(userJson))
            .toList();
      } else {
        // Initialize with test data from assets
        await _initializeFromAssets();
      }
      
      return _cachedUsers ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveUsers(List<User> users) async {
    final file = await _getUsersFile();
    final jsonData = {
      'users': users.map((user) => user.toJson()).toList(),
    };
    await file.writeAsString(json.encode(jsonData));
  }

  Future<File> _getUsersFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  // Method to get the file path for debugging
  Future<String> getFilePath() async {
    final file = await _getUsersFile();
    return file.path;
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
}