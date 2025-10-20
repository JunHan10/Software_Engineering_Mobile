import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/models/message.dart';
import '../../core/services/message_service.dart';
import '../../core/services/session_service.dart';
import '../../core/services/loan_service.dart';
import '../../core/services/api_service.dart';

/// ConversationPage - Shows messages in a specific conversation
/// 
/// This page displays the chat interface for a conversation between users,
/// allowing them to send messages and manage the borrowing request.
class ConversationPage extends StatefulWidget {
  final Conversation conversation;
  final String currentUserId;

  const ConversationPage({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    
    try {
      final messages = await MessageService.getConversationMessages(widget.conversation.id!);
      
      if (mounted) {
        setState(() {
          _messages = messages;
          _loading = false;
        });
        
        // Mark messages as read
        await MessageService.markMessagesAsRead(
          widget.conversation.id!,
          widget.currentUserId,
        );
        
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted) {
        setState(() {
          _messages = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _sending) return;

    setState(() => _sending = true);
    _messageController.clear();

    try {
      final user = await SessionService.getCurrentUser();
      if (user != null) {
        final message = await MessageService.sendMessage(
          conversationId: widget.conversation.id!,
          senderId: user.id!,
          senderName: '${user.firstName} ${user.lastName}'.trim(),
          content: content,
        );

        if (message != null && mounted) {
          setState(() {
            _messages.add(message);
          });

          // Scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _sendBorrowRequest() async {
    try {
      final user = await SessionService.getCurrentUser();
      if (user != null) {
        final message = await MessageService.sendMessage(
          conversationId: widget.conversation.id!,
          senderId: user.id!,
          senderName: '${user.firstName} ${user.lastName}'.trim(),
          content: 'I would like to borrow your ${widget.conversation.itemName}. Please let me know if this works for you!',
          type: MessageType.request,
        );

        if (message != null && mounted) {
          setState(() {
            _messages.add(message);
          });

          // Scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } catch (e) {
      print('Error sending borrow request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send borrow request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _approveBorrowRequest() async {
    try {
      final user = await SessionService.getCurrentUser();
      if (user != null) {
        // First, get the item details from the API
        final itemDetails = await _getItemDetails();
        if (itemDetails == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not find item details'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Create the loan record
        final loan = await LoanService.createLoan(
          itemId: widget.conversation.itemId,
          itemName: widget.conversation.itemName,
          itemDescription: itemDetails['description'] ?? '',
          itemImagePath: (itemDetails['imagePaths'] as List?)?.isNotEmpty == true 
              ? (itemDetails['imagePaths'] as List).first.toString() 
              : '',
          ownerId: widget.conversation.ownerId,
          ownerName: widget.conversation.ownerName,
          borrowerId: widget.conversation.borrowerId,
          borrowerName: widget.conversation.borrowerName,
          itemValue: (itemDetails['value'] ?? 0.0).toDouble(),
          expectedReturnDate: DateTime.now().add(const Duration(days: 7)), // Default 7 days
          notes: 'Approved via chat conversation',
        );

        if (loan == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create loan record'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Send approval message
        final message = await MessageService.sendMessage(
          conversationId: widget.conversation.id!,
          senderId: user.id!,
          senderName: '${user.firstName} ${user.lastName}'.trim(),
          content: 'Great! I approve your request to borrow my ${widget.conversation.itemName}. The item has been added to your active loans. Let\'s arrange a time to meet up!',
          type: MessageType.approval,
        );

        if (message != null && mounted) {
          setState(() {
            _messages.add(message);
          });

          // Update conversation status
          await MessageService.updateConversationStatus(
            conversationId: widget.conversation.id!,
            status: ConversationStatus.completed,
          );

          // Scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Borrow request approved! Item added to active loans.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error approving borrow request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to approve borrow request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> _getItemDetails() async {
    try {
      final assetsData = await ApiService.getAssets();
      for (final assetData in assetsData) {
        final assetId = assetData['_id'] ?? assetData['id'];
        if (assetId == widget.conversation.itemId) {
          return assetData;
        }
      }
      return null;
    } catch (e) {
      print('Error getting item details: $e');
      return null;
    }
  }

  Future<void> _rejectBorrowRequest() async {
    try {
      final user = await SessionService.getCurrentUser();
      if (user != null) {
        final message = await MessageService.sendMessage(
          conversationId: widget.conversation.id!,
          senderId: user.id!,
          senderName: '${user.firstName} ${user.lastName}'.trim(),
          content: 'I\'m sorry, but I cannot lend my ${widget.conversation.itemName} at this time.',
          type: MessageType.rejection,
        );

        if (message != null && mounted) {
          setState(() {
            _messages.add(message);
          });

          // Update conversation status
          await MessageService.updateConversationStatus(
            conversationId: widget.conversation.id!,
            status: ConversationStatus.cancelled,
          );

          // Scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } catch (e) {
      print('Error rejecting borrow request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject borrow request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == widget.currentUserId;
    final isOwner = widget.conversation.ownerId == widget.currentUserId;
    final isBorrower = widget.conversation.borrowerId == widget.currentUserId;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF87AE73),
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _getMessageColor(message.type, isMe),
                borderRadius: BorderRadius.circular(20),
                border: _getMessageBorder(message.type),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (!isMe) const SizedBox(height: 2),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: _getMessageTextColor(message.type, isMe),
                      fontSize: 16,
                      fontWeight: _getMessageFontWeight(message.type),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isMe ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                  // Action buttons for specific message types
                  if (message.type == MessageType.request && !isMe && isOwner) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: _approveBorrowRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text('Approve', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _rejectBorrowRequest,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text('Decline', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Text(
                'Me',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getMessageColor(MessageType type, bool isMe) {
    switch (type) {
      case MessageType.request:
        return isMe ? Colors.blue[100]! : Colors.blue[50]!;
      case MessageType.approval:
        return isMe ? Colors.green[100]! : Colors.green[50]!;
      case MessageType.rejection:
        return isMe ? Colors.red[100]! : Colors.red[50]!;
      default:
        return isMe ? const Color(0xFF87AE73) : Colors.grey[200]!;
    }
  }

  Color _getMessageTextColor(MessageType type, bool isMe) {
    switch (type) {
      case MessageType.request:
        return Colors.blue[800]!;
      case MessageType.approval:
        return Colors.green[800]!;
      case MessageType.rejection:
        return Colors.red[800]!;
      default:
        return isMe ? Colors.white : Colors.black87;
    }
  }

  FontWeight _getMessageFontWeight(MessageType type) {
    switch (type) {
      case MessageType.request:
      case MessageType.approval:
      case MessageType.rejection:
        return FontWeight.w600;
      default:
        return FontWeight.normal;
    }
  }

  Border? _getMessageBorder(MessageType type) {
    switch (type) {
      case MessageType.request:
        return Border.all(color: Colors.blue[300]!, width: 1);
      case MessageType.approval:
        return Border.all(color: Colors.green[300]!, width: 1);
      case MessageType.rejection:
        return Border.all(color: Colors.red[300]!, width: 1);
      default:
        return null;
    }
  }

  Widget _buildItemInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF87AE73).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory,
              color: Color(0xFF87AE73),
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discussing borrowing arrangements',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conversation.ownerId == widget.currentUserId
                  ? widget.conversation.borrowerName
                  : widget.conversation.ownerName,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              widget.conversation.itemName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildItemInfo(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet. Start the conversation!',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Request to Borrow button (only for borrowers)
                if (widget.conversation.borrowerId == widget.currentUserId && 
                    widget.conversation.status == ConversationStatus.active)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton.icon(
                      onPressed: _sendBorrowRequest,
                      icon: const FaIcon(FontAwesomeIcons.hand, size: 16),
                      label: const Text('Request to Borrow'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF87AE73),
                        side: const BorderSide(color: Color(0xFF87AE73)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                // Message input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF87AE73),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _sending ? null : _sendMessage,
                        icon: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const FaIcon(
                                FontAwesomeIcons.paperPlane,
                                color: Colors.white,
                                size: 16,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
