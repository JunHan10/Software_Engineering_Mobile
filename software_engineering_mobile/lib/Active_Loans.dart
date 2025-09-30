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
  List<dynamic> _loans = []; // TODO: Replace with your actual loan model

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
    // Example: _loans = await loanRepository.getActiveLoansByUserId(_userId);
    // setState(() { _loans = fetchedLoans; });
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Please log in',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to view your active loans and borrowing history.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF87AE73).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.download_outlined,
                size: 80,
                color: const Color(0xFF87AE73),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Loans',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t borrowed any items yet.\nStart exploring the marketplace to find items you need!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to dashboard (Home tab)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.explore),
              label: const Text('Browse Marketplace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87AE73),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                // Navigate to Post tab (Loaned Items)
                Navigator.of(context).popUntil((route) => route.isFirst);
                // This would need to be handled by the parent navigation
                // For now, just show a message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Switch to the "Post" tab to lend your items!'),
                    backgroundColor: Color(0xFF87AE73),
                  ),
                );
              },
              icon: const Icon(Icons.upload),
              label: const Text('Lend Your Items Instead'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF87AE73),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoansList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _loans.length,
      itemBuilder: (context, index) {
        final _loan = _loans[index]; // ignore: unused_local_variable
        // TODO: Replace with your actual loan item widget
        // Example: return LoanItemWidget(loan: loan);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text('Loan #${index + 1}'), // TODO: Replace with loan.title
            subtitle: Text('Status: Active'), // TODO: Replace with loan.status
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to loan details
              // Navigator.push(context, MaterialPageRoute(builder: (context) => LoanDetailsPage(loan: loan)));
            },
          ),
        );
      },
    );
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
          ? _buildLoginPrompt()
          : _loans.isEmpty
          ? _buildEmptyState()
          : _buildLoansList(),
    );
  }
}
