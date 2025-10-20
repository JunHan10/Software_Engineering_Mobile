// lib/features/loans/active_loans.dart
//
// Uses AuthService to resolve the active user id. Once you have your
// real loans data source, fetch by userId inside _load().

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/services/session_service.dart';

class ActiveLoans extends StatefulWidget {
  final VoidCallback? onNavigateToHome;
  final VoidCallback? onNavigateToPost;
  
  const ActiveLoans({super.key, this.onNavigateToHome, this.onNavigateToPost});

  @override
  State<ActiveLoans> createState() => _ActiveLoansState();
}

class _ActiveLoansState extends State<ActiveLoans> {

  String? _userId;
  bool _loading = true;
  final List<dynamic> _loans = []; // TODO: Replace with your actual loan model

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await SessionService.getCurrentUserId();
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
            FaIcon(
              FontAwesomeIcons.arrowRightToBracket,
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
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
              child: FaIcon(
                FontAwesomeIcons.download,
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
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to dashboard (Home tab)
                if (widget.onNavigateToHome != null) {
                  widget.onNavigateToHome!();
                } else {
                  // Fallback: try to pop back to first route
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              icon: const FaIcon(FontAwesomeIcons.compass),
              label: const Text('Browse Marketplace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87AE73),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                // Navigate to Post tab (Loaned Items)
                if (widget.onNavigateToPost != null) {
                  widget.onNavigateToPost!();
                } else {
                  // Fallback: show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Switch to the "Post" tab to lend your items!',
                      ),
                      backgroundColor: Color(0xFF87AE73),
                    ),
                  );
                }
              },
              icon: const FaIcon(FontAwesomeIcons.arrowUp),
              label: const Text('Lend Your Items Instead'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF87AE73),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
        final loan = _loans[index]; // ignore: unused_local_variable
        // TODO: Replace with your actual loan item widget
        // Example: return LoanItemWidget(loan: loan);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const FaIcon(FontAwesomeIcons.receipt),
            title: Text('Loan #${index + 1}'), // TODO: Replace with loan.title
            subtitle: Text('Status: Active'), // TODO: Replace with loan.status
            trailing: const FaIcon(FontAwesomeIcons.chevronRight),
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
