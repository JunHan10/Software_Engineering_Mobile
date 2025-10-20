import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

/// MessageService - Handles all messaging-related API calls
/// 
/// This service manages conversations and messages between users for the borrowing system.
/// It provides methods to create conversations, send messages, and retrieve conversation history.
class MessageService {
  static const String baseUrl = 'http://192.168.1.144:3000/api';

  /// Create a new conversation between a borrower and item owner
  static Future<Conversation?> createConversation({
    required String itemId,
    required String itemName,
    required String ownerId,
    required String ownerName,
    required String borrowerId,
    required String borrowerName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/conversations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'itemId': itemId,
          'itemName': itemName,
          'ownerId': ownerId,
          'ownerName': ownerName,
          'borrowerId': borrowerId,
          'borrowerName': borrowerName,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Conversation.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error creating conversation: $e');
      return null;
    }
  }

  /// Get all conversations for a user
  static Future<List<Conversation>> getUserConversations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Conversation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting user conversations: $e');
      return [];
    }
  }

  /// Get a specific conversation by ID
  static Future<Conversation?> getConversation(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$conversationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Conversation.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting conversation: $e');
      return null;
    }
  }

  /// Get messages for a conversation
  static Future<List<Message>> getConversationMessages(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$conversationId/messages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Message.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting conversation messages: $e');
      return [];
    }
  }

  /// Send a message in a conversation
  static Future<Message?> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/conversations/$conversationId/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': senderId,
          'senderName': senderName,
          'content': content,
          'type': type.toString().split('.').last,
          'metadata': metadata,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Message.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  /// Mark messages as read
  static Future<bool> markMessagesAsRead(String conversationId, String userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/conversations/$conversationId/read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking messages as read: $e');
      return false;
    }
  }

  /// Update conversation status
  static Future<bool> updateConversationStatus({
    required String conversationId,
    required ConversationStatus status,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/conversations/$conversationId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': status.toString().split('.').last,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating conversation status: $e');
      return false;
    }
  }

  /// Check if a conversation exists for an item between two users
  static Future<Conversation?> findExistingConversation({
    required String itemId,
    required String borrowerId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/find'),
        headers: {'Content-Type': 'application/json'},
        // Add query parameters
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data != null ? Conversation.fromJson(data) : null;
      }
      return null;
    } catch (e) {
      print('Error finding existing conversation: $e');
      return null;
    }
  }
}
