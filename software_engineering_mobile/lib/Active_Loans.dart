// lib/Active_Loans.dart
//
// Uses AuthService to resolve the active user id. Once you have your
// real loans data source, fetch by userId inside _load().

import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class ActiveLoans extends StatefulWidget {
  const ActiveLoans({super.key});

  @override
  State<ActiveLoans> createState() => _ActiveLoansState();
}

class _ActiveLoansState extends State<ActiveLoans> {
  final _auth = AuthService();
  String? _userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await _auth.getCurrentUserId();
    if (!mounted) return;
    setState(() {
      _userId = id;
      _loading = false;
    });

    // TODO: with _userId, fetch this user's loans from your real data source.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Loans'),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_userId == null)
          ? const Center(child: Text('Please log in to view your loans.'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          // TODO: Replace with your actual loans
          ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text('No active loans found'),
            subtitle: Text('Your loans will appear here.'),
          ),
        ],
      ),
    );
  }
}
