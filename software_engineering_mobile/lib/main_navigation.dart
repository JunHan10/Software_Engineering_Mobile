import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_page.dart';
import 'messages.dart';
import 'Loaned_Items.dart';
import 'Active_Loans.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  /// List of pages to navigate
  final List<Widget> _pages = [
    DashboardPage(),
    Loaned_Items(),
    ActiveLoans(),
    MessagesPage(),
  ];


  void _onItemTapped(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Borrow'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Inbox'),
        ],
        backgroundColor: Color.fromARGB(255, 231, 228, 213),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}