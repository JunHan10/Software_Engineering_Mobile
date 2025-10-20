import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/models/message.dart';
import '../../core/services/message_service.dart';
import '../../core/services/session_service.dart';
import 'conversation_page.dart';

/// ConversationListPage - Shows all conversations for the current user
/// 
/// This page displays a list of all conversations the user is involved in,
/// showing the most recent message and unread count for each conversation.
class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key});

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  List<Conversation> _conversations = [];
  bool _loading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _loading = true);
    
    try {
      final user = await SessionService.getCurrentUser();
      if (user?.id != null) {
        _currentUserId = user!.id!;
        final conversations = await MessageService.getUserConversations(user.id!);
        
        if (mounted) {
          setState(() {
            _conversations = conversations;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _conversations = [];
            _loading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading conversations: $e');
      if (mounted) {
        setState(() {
          _conversations = [];
          _loading = false;
        });
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildConversationItem(Conversation conversation) {
    final isOwner = conversation.ownerId == _currentUserId;
    final otherUserName = isOwner ? conversation.borrowerName : conversation.ownerName;
    final otherUserInitial = otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : 'U';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF87AE73),
          child: Text(
            otherUserInitial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherUserName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (conversation.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF87AE73),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conversation.itemName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    conversation.lastMessage?.content ?? 'No messages yet',
                    style: TextStyle(
                      color: conversation.unreadCount > 0 
                          ? Colors.black87 
                          : Colors.grey[600],
                      fontWeight: conversation.unreadCount > 0 
                          ? FontWeight.w500 
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatTime(conversation.updatedAt),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationPage(
                conversation: conversation,
                currentUserId: _currentUserId!,
              ),
            ),
          );
          
          // Refresh conversations if a message was sent
          if (result == true) {
            await _loadConversations();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF87AE73).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const FaIcon(
                FontAwesomeIcons.message,
                size: 80,
                color: Color(0xFF87AE73),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Conversations Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start a conversation by clicking "Borrow" on an item!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  color: const Color(0xFF87AE73),
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      return _buildConversationItem(_conversations[index]);
                    },
                  ),
                ),
    );
  }
}
