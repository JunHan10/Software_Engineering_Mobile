// lib/services/vote_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Vote values: 1 (upvote), -1 (downvote), 0 (no vote)
class VoteService {
  static String _keyForItem(String itemId) => 'votes_$itemId';

  // Returns map of userId -> vote value
  static Future<Map<String, int>> _loadVotes(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForItem(itemId));
    if (raw == null || raw.isEmpty) return <String, int>{};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return <String, int>{};
    }
  }

  static Future<void> _saveVotes(String itemId, Map<String, int> votes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyForItem(itemId), jsonEncode(votes));
  }

  static Future<int> getScore(String itemId) async {
    final votes = await _loadVotes(itemId);
    return votes.values.fold<int>(0, (sum, v) => sum + v);
  }

  static Future<int> getUserVote(String itemId, String userId) async {
    final votes = await _loadVotes(itemId);
    return votes[userId] ?? 0;
  }

  static Future<int> setVote({
    required String itemId,
    required String userId,
    required int vote, // -1, 0, 1
  }) async {
    if (vote < -1 || vote > 1) vote = 0;
    final votes = await _loadVotes(itemId);
    if (vote == 0) {
      votes.remove(userId);
    } else {
      votes[userId] = vote;
    }
    await _saveVotes(itemId, votes);
    return votes.values.fold<int>(0, (sum, v) => sum + v);
  }
}


