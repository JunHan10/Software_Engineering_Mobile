import 'package:flutter/material.dart';

class ActiveLoans extends StatelessWidget {
  const ActiveLoans({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Loans'),
        backgroundColor: Color(0xFF87AE73),
        foregroundColor: Color(0xFFede6c7),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'This is the New Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Both buttons navigate to this page.'),
            ],
          ),
        ),
      ),
    );
  }
}