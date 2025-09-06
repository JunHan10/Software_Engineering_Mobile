import 'package:flutter/material.dart';
import 'package:software_engineering_mobile/Active_Loans.dart';
import 'login_screen.dart';
import 'Loaned_Items.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Dashboard'),
            const SizedBox(width: 50),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Loaned_Items()),
                );
              },
              child: const Text(
                'Loaned Items',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActiveLoans()),
                );
              },
              child: const Text(
                'Active Loans',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const Spacer(),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: const Text(
              'Currency Goes Here',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement( 
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()
              ),
            );
          },
       ) ]
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}