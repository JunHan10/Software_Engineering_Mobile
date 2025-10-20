/// Message Model - Represents a message in a conversation
/// 
/// This class handles individual messages between users for the borrowing/lending system.
/// Messages are linked to conversations and include metadata for proper display and management.
class Message {
  final String? id; // Database ID
  final String conversationId; // ID of the conversation this message belongs to
  final String senderId; // ID of the user who sent the message
  final String senderName; // Name of the sender (for display purposes)
  final String content; // The actual message content
  final DateTime createdAt; // When the message was sent
  final MessageType type; // Type of message (text, image, system, etc.)
  final bool isRead; // Whether the message has been read by the recipient
  final Map<String, dynamic>? metadata; // Additional data (image URLs, etc.)

  const Message({
    this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
    this.type = MessageType.text,
    this.isRead = false,
    this.metadata,
  });

  /// Factory constructor for creating Message objects from JSON data
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'],
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      isRead: json['isRead'] ?? false,
      metadata: json['metadata'],
    );
  }

  /// Converts Message object to JSON Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  /// Create a copy of the message with updated values
  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? createdAt,
    MessageType? type,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Conversation Model - Represents a conversation between users
/// 
/// This class manages conversations between users, typically initiated when someone
/// wants to borrow an item. Each conversation is linked to a specific item.
class Conversation {
  final String? id; // Database ID
  final String itemId; // ID of the item being discussed
  final String itemName; // Name of the item (for display purposes)
  final String ownerId; // ID of the item owner
  final String ownerName; // Name of the item owner
  final String borrowerId; // ID of the person wanting to borrow
  final String borrowerName; // Name of the borrower
  final DateTime createdAt; // When the conversation was created
  final DateTime updatedAt; // When the conversation was last updated
  final ConversationStatus status; // Current status of the conversation
  final Message? lastMessage; // The most recent message in the conversation
  final int unreadCount; // Number of unread messages for the current user

  const Conversation({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.ownerId,
    required this.ownerName,
    required this.borrowerId,
    required this.borrowerName,
    required this.createdAt,
    required this.updatedAt,
    this.status = ConversationStatus.active,
    this.lastMessage,
    this.unreadCount = 0,
  });

  /// Factory constructor for creating Conversation objects from JSON data
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'] ?? json['id'],
      itemId: json['itemId'] ?? '',
      itemName: json['itemName'] ?? '',
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      borrowerId: json['borrowerId'] ?? '',
      borrowerName: json['borrowerName'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      status: ConversationStatus.values.firstWhere(
        (e) => e.toString() == 'ConversationStatus.${json['status']}',
        orElse: () => ConversationStatus.active,
      ),
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage']) 
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  /// Converts Conversation object to JSON Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
    };
  }

  /// Create a copy of the conversation with updated values
  Conversation copyWith({
    String? id,
    String? itemId,
    String? itemName,
    String? ownerId,
    String? ownerName,
    String? borrowerId,
    String? borrowerName,
    DateTime? createdAt,
    DateTime? updatedAt,
    ConversationStatus? status,
    Message? lastMessage,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      borrowerId: borrowerId ?? this.borrowerId,
      borrowerName: borrowerName ?? this.borrowerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Enum for different types of messages
enum MessageType {
  text,
  image,
  system,
  request,
  approval,
  rejection,
}

/// Enum for conversation status
enum ConversationStatus {
  active,
  completed,
  cancelled,
  archived,
}
