import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile.dart';

/// DashboardPage - Main landing page after successful user authentication
/// 
/// This is a StatelessWidget because the dashboard doesn't need to maintain
/// any internal state - it's purely a navigation hub with static content.
/// 
/// Key Features:
/// - Clean AppBar with currency display and logout functionality
/// - Two main navigation buttons for core app features
/// - Debug buttons for development and testing (should be removed in production)
/// - Consistent theming with deep purple color scheme
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Color(0xFF87AE73),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: const Text(
              'Currency Here',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );  
              },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/login_icon.png'), // Replace with better icons
              backgroundColor: Colors.white,
              )
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Color(0xFF87AE73), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),

              // Additional content can go here
            ],
          ),
        ),
      )
    );
  }
}