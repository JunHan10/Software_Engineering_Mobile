import 'package:flutter/material.dart';

class ActiveLoans extends StatelessWidget {
  const ActiveLoans({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Loans'),
        backgroundColor: Color(0xFF87AE73),
        foregroundColor: Colors.white,
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
          
            ],
          ),
        ),
      ),
    );
  }
}