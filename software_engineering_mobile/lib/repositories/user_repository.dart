import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user.dart';

/**
 * UserRepository - Repository interface for user persistence
 *
 * This interface abstracts read/write operations for User data so the app
 * can swap between different backends (local file, SharedPreferences, DB, API).
 */
abstract class UserRepository {
  // Core read operations
  Future<User?> findByEmail(String email);
  Future<User?> findByEmailAndPassword(String email, String password);

  // Core write operations
  Future<User> save(User user);
  Future<void> delete(String id);

  // NEW: Hippopotamoney helpers ---------------------------------------------
  /// Returns the current Hippopotamoney balance in cents for the given userId.
  Future<int> getHippoBalanceCents(String userId);

  /// Sets the Hippopotamoney balance (in cents) for the given userId.
  Future<void> setHippoBalanceCents(String userId, int newBalanceCents);

  /// Deposits the given amount (in cents) to the user's Hippopotamoney balance.
  Future<int> depositHippoCents(String userId, int amountCents);

  /// Withdraws the given amount (in cents) from the user's Hippopotamoney balance (clamped at 0).
  Future<int> withdrawHippoCents(String userId, int amountCents);
}

/*
 * NOTE:
 * Your original file showed additional classes (e.g., JsonUserRepository) and
 * dev-utility methods with SharedPreferences cleanup. Those aren’t needed here,
 * since concrete implementations live in:
 *  - local_user_repository.dart
 *  - shared_prefs_user_repository.dart
 *
 * If you want me to keep a specific extra class in THIS file, paste the full
 * version (without the "..." truncation) and I’ll re-apply these Hippopotamoney
 * methods to it while keeping every comment intact.
 */
