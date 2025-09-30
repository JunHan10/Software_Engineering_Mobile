import 'package:flutter/material.dart';

// Sample data
class ChatUser {
  final String name;
  final String lastMessage;
  final String avatar;
  final String time;
  ChatUser(this.name, this.lastMessage, this.avatar, this.time);
}

class MessagesPage extends StatelessWidget {
  final List<ChatUser> users = [
    ChatUser('Johnny Doe', 'Lorem Ipsum is simply dummy...', 'assets/default_user.png', '08:10'),
    ChatUser('Adrian', 'Excepteur sint occaecat...', 'assets/default_user.png', '03:19'),
    ChatUser('Fiona', 'Hii... 😎', 'assets/default_user.png', '02:53'),
    ChatUser('Emma', 'Consectetur adipiscing elit', 'assets/default_user.png', '11:39'),
    ChatUser('Alexander', 'Duis aute irure dolor...', 'assets/default_user.png', '00:09'),
    ChatUser('Alsoher', 'Duis aute irure dolor...', 'assets/default_user.png', '00:09'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with your friends'),
        backgroundColor: Colors.blue[800],
      ),
      body: Column(
        children: [
          // Horizontal avatars
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: users.map((user) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage(user.avatar),
                  ),
                );
              }).toList(),
            ),
          ),
          // Vertical chat list
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(user.avatar),
                  ),
                  title: Text(user.name),
                  subtitle: Text(
                    user.lastMessage,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(user.time),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          userName: user.name,
                          avatar: user.avatar,
                          lastMessage: user.lastMessage,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Chat page
class ChatPage extends StatefulWidget {
  final String userName;
  final String lastMessage;
  final String avatar;
  const ChatPage({
    super.key,
    required this.userName,
    required this.lastMessage,
    required this.avatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add last message initially
    messages.add({
      "sender": widget.userName,
      "text": widget.lastMessage,
      "time": widgetTime(),
    });
  }

  String widgetTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      // Add user message
      messages.add({"sender": "You", "text": text, "time": widgetTime()});
      _controller.clear();
      _scrollToBottom();

      // Simulate reply
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          messages.add({
            "sender": widget.userName,
            "text": "Reply to '$text'",
            "time": widgetTime()
          });
          _scrollToBottom();
        });
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.avatar),
            ),
            SizedBox(width: 8),
            Text(widget.userName),
          ],
        ),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.call)),
          IconButton(onPressed: () {}, icon: Icon(Icons.videocam)),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender'] == 'You';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(msg['text']!, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 2),
                        Text(msg['time']!,
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue[800],
                  child: IconButton(
                    onPressed: () => _sendMessage(_controller.text),
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
