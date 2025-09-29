// lib/dashboard_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

// Screens
import 'login_screen.dart';
//import 'profile/profile_page.dart';
import 'legacy_profile.dart';

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
              MoneyService.formatCents(_hippoBalanceCents),
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
                _loadBalance();
                _loadProfileImage();
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
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
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
              const SizedBox(height: 16),
              // Marketplace-style grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  final items = [
                    {"title": "Mountain Bike", "price": "HB 120.00", "image": Icons.directions_bike},
                    {"title": "Laptop", "price": "HB 350.00", "image": Icons.laptop_mac},
                    {"title": "Guitar", "price": "HB 80.00", "image": Icons.music_note},
                    {"title": "Desk Chair", "price": "HB 45.00", "image": Icons.chair},
                    {"title": "Textbooks", "price": "HB 60.00", "image": Icons.menu_book},
                    {"title": "Coffee Maker", "price": "HB 25.00", "image": Icons.coffee},
                    {"title": "Headphones", "price": "HB 30.00", "image": Icons.headphones},
                    {"title": "Soccer Ball", "price": "HB 15.00", "image": Icons.sports_soccer},
                  ];
                  final item = items[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item["image"] as IconData, size: 48, color: Color(0xFF87AE73)),
                            const SizedBox(height: 12),
                            Text(
                              item["title"] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item["price"] as String,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
