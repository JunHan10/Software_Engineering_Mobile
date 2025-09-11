import 'package:flutter/material.dart';
import 'dashboard_page.dart';
// import 'search_page.dart';
import 'profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  /// List of pages to navigate (replace "center" with actual pages)
  final List<Widget> _pages = [
    DashboardPage(),
    Center(child: Text('New Item Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Messages Page', style: TextStyle(fontSize: 24))),
    ProfilePage(),
  ];


  void _onItemTapped(int index) {
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
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'New'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Profile'),
        ],
        backgroundColor: Color.fromARGB(255, 231, 228, 213),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
