import 'dart:async';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'dashboard_page.dart';
import 'messages.dart';
import 'Loaned_Items.dart';
import 'Active_Loans.dart';
//import 'profile/profile_page.dart';
import 'legacy_profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  int? _pressedIndex;
  Timer? _pressedTimer;

  /// List of pages to navigate
  final List<Widget> _pages = [
    DashboardPage(),
    Loaned_Items(),
    ActiveLoans(),
    MessagesPage(),
    ProfilePage(),
  ];


  void _onItemTapped(int index) {
    HapticFeedback.mediumImpact();
    // Force animation by briefly setting pressed state
    setState(() {
      _pressedIndex = index;
      _selectedIndex = index;
    });
    // Clear pressed state after animation
    Timer(Duration(milliseconds: 200), () {
      if (mounted) setState(() => _pressedIndex = null);
    });
  }

  Widget _buildNavButton(int index, IconData icon, String label) {
    final bool isSelected = index == _selectedIndex;
    final bool isPressed = _pressedIndex == index;
    final double dy = isPressed ? 6.0 : (isSelected ? 2.0 : 0.0);
    final baseColor = Color.fromARGB(255, 231, 228, 213);
    
    return Expanded(
      child: Container(
        height: 70,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onItemTapped(index),
            onTapDown: (_) {
              _pressedTimer?.cancel();
              setState(() => _pressedIndex = index);
            },
            onTapUp: (_) {
              _pressedTimer = Timer(Duration(milliseconds: 150), () {
                if (mounted) setState(() => _pressedIndex = null);
              });
            },
            onTapCancel: () {
              _pressedTimer = Timer(Duration(milliseconds: 150), () {
                if (mounted) setState(() => _pressedIndex = null);
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              decoration: isSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: baseColor.withValues(alpha: 0.9),
                      boxShadow: [
                        // Top inset shadow - deeper when pressed
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isPressed ? 0.4 : 0.2),
                          offset: Offset(0, isPressed ? 4 : 2),
                          blurRadius: isPressed ? 8 : 4,
                          inset: true,
                        ),
                        // Bottom inset highlight
                        BoxShadow(
                          color: Colors.white.withValues(alpha: isPressed ? 0.8 : 0.6),
                          offset: Offset(0, isPressed ? -2 : -1),
                          blurRadius: isPressed ? 4 : 2,
                          inset: true,
                        ),
                      ],
                    )
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.bounceOut,
                    transform: Matrix4.translationValues(0, dy, 0),
                    child: Icon(
                      icon,
                      color: isSelected ? Color(0xFF87AE73) : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Color(0xFF87AE73) : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: Container(
        color: Color.fromARGB(255, 231, 228, 213),
        child: Row(
          children: [
            _buildNavButton(0, Icons.home, 'Home'),
            _buildNavButton(1, Icons.upload, 'Post'),
            _buildNavButton(2, Icons.download, 'Borrow'),
            _buildNavButton(3, Icons.message, 'Inbox'),
            _buildNavButton(4, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }
}