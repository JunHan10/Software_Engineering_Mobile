import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import '../../core/services/session_service.dart';
import '../../core/models/user.dart';
import 'login_screen.dart';

/// SwitchAccountsPage - Allows users to switch between different accounts
///
/// This page displays all available users and allows the current user to switch
/// to a different account by selecting from the list.
class SwitchAccountsPage extends StatefulWidget {
  const SwitchAccountsPage({super.key});

  @override
  State<SwitchAccountsPage> createState() => _SwitchAccountsPageState();
}

class _SwitchAccountsPageState extends State<SwitchAccountsPage> {
  List<User> _users = [];
  bool _loading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);

    try {
      // Get current user ID
      final currentUser = await SessionService.getCurrentUser();
      _currentUserId = currentUser?.id;

      // Load all users
      final usersData = await ApiService.getUsers();
      final users = usersData
          .map((userJson) => User.fromJson(userJson))
          .toList();

      if (mounted) {
        setState(() {
          _users = users;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading users: $e');
      if (mounted) {
        setState(() {
          _users = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _switchToUser(User user) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Switch Account'),
          content: Text(
            'Are you sure you want to switch to ${user.firstName} ${user.lastName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Switch'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Save the new user ID to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('activeUserId', user.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to ${user.firstName} ${user.lastName}'),
              backgroundColor: const Color(0xFF87AE73),
            ),
          );

          // Navigate back to login, pre-filling the email for convenience
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(initialEmail: user.email),
            ),
          );
        }
      }
    } catch (e) {
      print('Error switching user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to switch account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUserCard(User user) {
    final isCurrentUser = user.id == _currentUserId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCurrentUser
              ? const Color(0xFF87AE73)
              : Colors.grey[300],
          child: Text(
            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
            style: TextStyle(
              color: isCurrentUser ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(user.email),
        trailing: isCurrentUser
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF87AE73),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Current',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const FaIcon(
                FontAwesomeIcons.arrowRight,
                size: 16,
                color: Colors.grey,
              ),
        onTap: isCurrentUser ? null : () => _switchToUser(user),
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
                FontAwesomeIcons.users,
                size: 80,
                color: Color(0xFF87AE73),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Users Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load user accounts',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
        title: const Text('Switch Account'),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadUsers,
              color: const Color(0xFF87AE73),
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  return _buildUserCard(_users[index]);
                },
              ),
            ),
    );
  }
}
