// lib/dashboard_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

// Screens
import 'package:software_engineering_mobile/Active_Loans.dart';
import 'Loaned_Items.dart';
import 'login_screen.dart';
import 'profile.dart';

// Repos & money formatting
import 'repositories/shared_prefs_user_repository.dart';
import 'services/money_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repo = SharedPrefsUserRepository();
  int _hippoBalanceCents = 0;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _loadProfileImage();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('activeUserId');
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      setState(() => _hippoBalanceCents = 0);
      return;
    }
    final bal = await _repo.getHippoBalanceCents(userId);
    if (!mounted) return;
    setState(() => _hippoBalanceCents = bal);
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_image_path');
    if (savedPath != null && File(savedPath).existsSync()) {
      setState(() {
        _profileImage = File(savedPath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Text(
              MoneyService.formatCents(_hippoBalanceCents), // "HB 0.00"
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
                if (!mounted) return;
                _loadBalance(); // refresh after coming back
                _loadProfileImage(); // refresh profile image
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? ProfilePicture(
                        name: 'John King',
                        radius: 18,
                        fontsize: 12,
                      )
                    : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
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
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF87AE73), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Dev/debug helpers used in your project
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('activeUserId');
                  final balance = (userId == null)
                      ? 0
                      : await _repo.getHippoBalanceCents(userId);
                  // ignore: avoid_print
                  print("Active user balance: ${MoneyService.formatCents(balance)}");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Debug: View Balance'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await _repo.clearAllData();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared! App will reload original test data.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setState(() => _hippoBalanceCents = 0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear All Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
