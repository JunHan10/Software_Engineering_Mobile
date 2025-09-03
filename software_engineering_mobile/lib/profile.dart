// Profile Page
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Center(
        child: Text(
          'Profile Information',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
