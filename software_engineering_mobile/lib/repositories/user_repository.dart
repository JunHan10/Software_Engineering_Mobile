// lib/repositories/user_repository.dart
//
// Abstraction over user storage. Works with local in-memory or SharedPreferences.
// Keep this interface small and intention-revealing.

import '../models/user.dart';

abstract class UserRepository {
  // ---- User identity / auth helpers ----
  Future<User?> findByEmail(String email);
  Future<User?> findByEmailAndPassword(String email, String password);
  Future<User?> findById(String id);

  // ---- Persistence ----
  Future<User> save(User user);        // insert or update
  Future<void> delete(String id);

  // ---- Hippo Bucks (HB) wallet API ----
  Future<int> getHippoBalanceCents(String userId);
  Future<void> setHippoBalanceCents(String userId, int newBalanceCents);
  Future<int> depositHippoCents(String userId, int amountCents);
  Future<int> withdrawHippoCents(String userId, int amountCents);

  // ---- Transactions ----
  Future<void> incrementTransactionCount(String userId);
  Future<int> getTransactionCount(String userId);


  // ---- Dev helpers (used in your UI debug buttons) ----
  Future<void> clearAllData();
  Future<void> printAllUsers();
}
