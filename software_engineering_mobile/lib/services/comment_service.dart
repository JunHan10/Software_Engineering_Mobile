// lib/services/comment_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Comment {
  final String id;
  final String itemId;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.itemId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'authorId': authorId,
        'authorName': authorName,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  static Comment fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String,
        itemId: json['itemId'] as String,
        authorId: json['authorId'] as String,
        authorName: json['authorName'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class CommentService {
  static String _key(String itemId) => 'comments_$itemId';

  static Future<List<Comment>> getComments(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(itemId));
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(Comment.fromJson).toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> addComment(Comment comment) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getComments(comment.itemId);
    final next = List<Comment>.from(existing)..add(comment);
    final jsonList = next.map((c) => c.toJson()).toList();
    await prefs.setString(_key(comment.itemId), jsonEncode(jsonList));
  }
}


