import 'package:flutter/material.dart';
import 'dashboard_page.dart';
<<<<<<< HEAD
import 'new_item_page.dart';
// import 'search_page.dart';
// import 'profile.dart';
=======
import 'Loaned_Items.dart';
import 'Active_Loans.dart';
import 'profile.dart';
>>>>>>> 1320677b7af9c34738d0d90ab7e21177271eeea9

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

<<<<<<< HEAD
  /// List of pages to navigate (replace "center" with actual pages)
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(),
      NewItemPage(
        onSaved: () {
          // After save, jump back to Home tab
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      Center(child: Text('Messages Page', style: TextStyle(fontSize: 24))),
    ];
  }
=======
  /// List of pages to navigate
  final List<Widget> _pages = [
    DashboardPage(),
    Loaned_Items(),
    ActiveLoans(),
    ProfilePage(),
  ];
>>>>>>> 1320677b7af9c34738d0d90ab7e21177271eeea9


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
