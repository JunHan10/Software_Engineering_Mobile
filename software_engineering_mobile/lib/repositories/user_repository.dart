import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user.dart';

abstract class UserRepository {
  Future<User?> findByEmail(String email);
  Future<User?> findByEmailAndPassword(String email, String password);
  Future<User> save(User user);
  Future<void> delete(String id);
}

// Current implementation using JSON file
class JsonUserRepository implements UserRepository {
  User? _cachedUser;

  @override
  Future<User?> findByEmail(String email) async {
    final user = await _loadUser();
    return (user?.email == email) ? user : null;
  }

  @override
  Future<User?> findByEmailAndPassword(String email, String password) async {
    final user = await _loadUser();
    return (user?.email == email && user?.password == password) ? user : null;
  }

  @override
  Future<User> save(User user) async {
    // For JSON implementation, this would write back to file
    // For database, this would insert/update in DB
    throw UnimplementedError('Save not implemented for JSON repository');
  }

  @override
  Future<void> delete(String id) async {
    throw UnimplementedError('Delete not implemented for JSON repository');
  }

  Future<User?> _loadUser() async {
    if (_cachedUser != null) return _cachedUser;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/test_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _cachedUser = User.fromJson(jsonData['user']);
      return _cachedUser;
    } catch (e) {
      return null;
    }
  }
}

// Future database implementation would look like:
/*
class DatabaseUserRepository implements UserRepository {
  @override
  Future<User?> findByEmail(String email) async {
    // Query database: SELECT * FROM users WHERE email = ?
  }
  
  @override
  Future<User?> findByEmailAndPassword(String email, String password) async {
    // Query database: SELECT * FROM users WHERE email = ? AND password = ?
  }
  
  @override
  Future<User> save(User user) async {
    // INSERT or UPDATE user in database
  }
  
  @override
  Future<void> delete(String id) async {
    // DELETE FROM users WHERE id = ?
  }
}
*/