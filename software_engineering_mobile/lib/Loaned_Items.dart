import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_item_page.dart';

class Loaned_Items extends StatelessWidget {
  const Loaned_Items({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loaned Assets'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewItemPage()),
          );
        },
        backgroundColor: Color(0xFF87AE73),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}