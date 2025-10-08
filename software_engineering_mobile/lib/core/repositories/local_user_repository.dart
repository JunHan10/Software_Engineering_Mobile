// lib/repositories/local_user_repository.dart
//
// Simple in-memory repository for testing. Not persisted across app restarts.

import 'dart:math';
import '../models/user.dart';
import 'user_repository.dart';

class LocalUserRepository implements UserRepository {
  final Map<String, User> _users = {};
  final Map<String, int> _balances = {}; // userId -> cents
  final Map<String, int> _transactionCounts = {}; // userId -> count

  String _newId() =>
      DateTime.now().microsecondsSinceEpoch.toString() +
          Random().nextInt(9999).toString();

  @override
  Future<User?> findByEmail(String email) async {
    try {
      return _users.values
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
    // NOTE: hash your password in production.
  }

  @override
  Future<User?> findById(String id) async => _users[id];

  @override
  Future<User> save(User user) async {
    final id = user.id ?? _newId();
    final toSave = user.id == null ? userCopyWith(user, id: id) : user;
    _users[id] = toSave;
    _balances.putIfAbsent(id, () => 0);
    return toSave;
  }

  @override
  Future<void> delete(String id) async {
    _users.remove(id);
    _balances.remove(id);
  }

  // ---------------- Hippo Bucks (HB) ----------------

  @override
  Future<int> getHippoBalanceCents(String userId) async =>
      _balances[userId] ?? 0;

  @override
  Future<void> setHippoBalanceCents(String userId, int newBalanceCents) async {
    // clamp to >= 0 (keep it int)
    final clamped = newBalanceCents < 0 ? 0 : newBalanceCents;
    _balances[userId] = clamped;
  }

  @override
  Future<int> depositHippoCents(String userId, int amountCents) async {
    final add = amountCents < 0 ? 0 : amountCents;
    final cur = await getHippoBalanceCents(userId);
    final next = cur + add; // stays int
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

  // ---------------- Transactions ----------------

  @override
  Future<void> incrementTransactionCount(String userId) async {
    final current = _transactionCounts[userId] ?? 0;
    _transactionCounts[userId] = current + 1;
  }

  @override
  Future<int> getTransactionCount(String userId) async =>
      _transactionCounts[userId] ?? 0;

  // ---------------- Dev helpers ----------------

  @override
  Future<void> clearAllData() async {
    _users.clear();
    _balances.clear();
    _transactionCounts.clear();
  }

  @override
  Future<void> printAllUsers() async {
    // ignore: avoid_print
    for (final u in _users.values) {
      print('User: ${u.id} ${u.email} ${u.firstName} ${u.lastName}');
    }
  }

  // helper to avoid depending on a model copyWith
  User userCopyWith(User u, {String? id}) => User(
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
