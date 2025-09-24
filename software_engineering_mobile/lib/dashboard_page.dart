// Flutter Material Design imports for UI components
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

// Import specific loan-related pages for navigation
import 'package:software_engineering_mobile/Active_Loans.dart';
import 'Loaned_Items.dart';
import 'login_screen.dart';
import 'profile.dart';

// Import repository + money service
import 'repositories/shared_prefs_user_repository.dart';
import 'services/money_service.dart';

/// DashboardPage - Main landing page after successful user authentication
///
/// This screen shows the current Hippo Bucks balance in the AppBar.
/// Balance is loaded from SharedPreferences using SharedPrefsUserRepository.
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
    // TODO: Replace this with the actual logged-in user ID (e.g., from SharedPreferences).
    // Until then, this placeholder will just show HB 0.00 unless a user with this id exists.
    const userId = 'active_user';
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
          // SHOW HB BALANCE (replaces the old "Currency Here")
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Text(
              MoneyService.formatCents(_hippoBalanceCents), // e.g. "HB 0.00"
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ),
          // Profile avatar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ).then((_) => _loadProfileImage()); // Refresh profile image when returning
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
              const SizedBox(height: 16),



              // Debug: view balance in console
              ElevatedButton(
                onPressed: () async {
                  const userId = 'active_user';
                  final balance = await _repo.getHippoBalanceCents(userId);
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

              // Debug: clear all data
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
                  setState(() => _hippoBalanceCents = 0); // reset UI
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
