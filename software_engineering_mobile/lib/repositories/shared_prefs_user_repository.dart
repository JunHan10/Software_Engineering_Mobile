// lib/repositories/shared_prefs_user_repository.dart
//
// SharedPreferences-backed repository. Stores:
// - Users: JSON array under key 'users_json'
// - HippoBucks per-user balance: int cents under key 'balance_<userId>'

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'user_repository.dart';

class SharedPrefsUserRepository implements UserRepository {
  static const _usersKey = 'users_json';
  static String _balKey(String userId) => 'balance_$userId';

  // ------------ internal helpers ------------

  Future<List<User>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) {
      await _initializeTestData();
      final newRaw = prefs.getString(_usersKey);
      if (newRaw == null || newRaw.isEmpty) return [];
      try {
        final list = (jsonDecode(newRaw) as List).cast<Map<String, dynamic>>();
        return list.map((m) => User.fromJson(m)).toList();
      } catch (_) {
        return [];
      }
    }
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map((m) => User.fromJson(m)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final list = users.map((u) => u.toJson()).toList();
    await prefs.setString(_usersKey, jsonEncode(list));
  }

  String _newId() =>
      DateTime.now().microsecondsSinceEpoch.toString() +
          Random().nextInt(9999).toString();

  // ------------ UserRepository impl ------------

  @override
  Future<User?> findByEmail(String email) async {
    final users = await _loadUsers();
    try {
      return users
          .firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User?> findByEmailAndPassword(String email, String password) async {
    final u = await findByEmail(email);
    if (u == null) return null;
    return (u.password == password) ? u : null;
  }

  @override
  Future<User?> findById(String id) async {
    final users = await _loadUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User> save(User user) async {
    final users = await _loadUsers();
    if (user.id == null || user.id!.isEmpty) {
      final newId = _newId();
      final withId = _copyUser(user, id: newId);
      users.add(withId);
      await _saveUsers(users);
      return withId;
    } else {
      final idx = users.indexWhere((u) => u.id == user.id);
      if (idx == -1) {
        users.add(user);
      } else {
        users[idx] = user;
      }
      await _saveUsers(users);
      return user;
    }
  }

  @override
  Future<void> delete(String id) async {
    final users = await _loadUsers();
    users.removeWhere((u) => u.id == id);
    await _saveUsers(users);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_balKey(id));
  }

  // ------------ HB wallet ------------

  @override
  Future<int> getHippoBalanceCents(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_balKey(userId)) ?? 0;
  }

  @override
  Future<void> setHippoBalanceCents(String userId, int newBalanceCents) async {
    final prefs = await SharedPreferences.getInstance();
    final clamped = newBalanceCents < 0 ? 0 : newBalanceCents; // keep int
    await prefs.setInt(_balKey(userId), clamped);
  }

  @override
  Future<int> depositHippoCents(String userId, int amountCents) async {
    final add = amountCents < 0 ? 0 : amountCents;
    final cur = await getHippoBalanceCents(userId);
    final next = cur + add;
    await setHippoBalanceCents(userId, next);
    return next;
  }

  @override
  Future<int> withdrawHippoCents(String userId, int amountCents) async {
    final sub = amountCents < 0 ? 0 : amountCents;
    final cur = await getHippoBalanceCents(userId);
    final next = cur - sub;
    final clamped = next < 0 ? 0 : next;
    await setHippoBalanceCents(userId, clamped);
    return clamped;
  }

  // ------------ Initialization ------------

  Future<void> _initializeTestData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/test_data.json');
      final jsonData = jsonDecode(jsonString);
      final usersList = (jsonData['users'] as List).cast<Map<String, dynamic>>();
      final users = usersList.map((m) => User.fromJson(m)).toList();
      await _saveUsers(users);
    } catch (e) {
      // If loading test data fails, create a default user
      final defaultUser = User(
        id: '1',
        email: 'john.doe@example.com',
        password: 'password123',
        firstName: 'John',
        lastName: 'Doe',
        currency: 2500.75,
        assets: const [],
        hippoBalanceCents: 0,
      );
      await _saveUsers([defaultUser]);
    }
  }

  // ------------ Dev helpers ------------

  @override
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _loadUsers();
    for (final u in users) {
      final id = u.id;
      if (id != null && id.isNotEmpty) {
        await prefs.remove(_balKey(id));
      }
    }
    await prefs.remove(_usersKey);
  }

  @override
  Future<void> printAllUsers() async {
    final users = await _loadUsers();
    for (final u in users) {
      final bal = await getHippoBalanceCents(u.id ?? '');
      // ignore: avoid_print
      print('User: ${u.id} ${u.email} ${u.firstName} ${u.lastName} | HB: ${bal}c');
    }
  }

  // helper to avoid requiring copyWith in the model
  User _copyUser(User u, {String? id}) => User(
    id: id ?? u.id,
    email: u.email,
    password: u.password,
    firstName: u.firstName,
    lastName: u.lastName,
    age: u.age,
    streetAddress: u.streetAddress,
    city: u.city,
    state: u.state,
    zipcode: u.zipcode,
    currency: u.currency,
    assets: u.assets,
    hippoBalanceCents: u.hippoBalanceCents,
  );
}
