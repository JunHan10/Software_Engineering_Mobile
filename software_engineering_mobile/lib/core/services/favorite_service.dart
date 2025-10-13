// lib/core/services/favorite_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static String _keyForUser(String userId) => 'favorites_$userId';

  // Returns set of favorited item IDs for a user
  static Future<Set<String>> _loadFavorites(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> _saveFavorites(String userId, Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyForUser(userId), jsonEncode(favorites.toList()));
  }

  static Future<bool> isFavorited(String itemId, String userId) async {
    final favorites = await _loadFavorites(userId);
    return favorites.contains(itemId);
  }

  static Future<void> toggleFavorite({
    required String itemId,
    required String userId,
  }) async {
    final favorites = await _loadFavorites(userId);
    if (favorites.contains(itemId)) {
      favorites.remove(itemId);
    } else {
      favorites.add(itemId);
    }
    await _saveFavorites(userId, favorites);
  }

  static Future<Set<String>> getUserFavorites(String userId) async {
    return await _loadFavorites(userId);
  }
}
