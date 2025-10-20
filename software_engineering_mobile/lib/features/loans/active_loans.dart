// lib/features/loans/active_loans.dart
//
// Uses AuthService to resolve the active user id. Once you have your
// real loans data source, fetch by userId inside _load().

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/services/session_service.dart';
import '../../core/services/loan_service.dart';
import '../../core/models/loan.dart';

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
  List<Loan> _loans = [];
  List<Loan> _borrowedItems = [];
  List<Loan> _lentItems = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    
    try {
      final id = await SessionService.getCurrentUserId();
      if (id != null) {
        // Load all loans for the user
        final allLoans = await LoanService.getUserActiveLoans(id);
        
        if (mounted) {
          setState(() {
            _userId = id;
            _loans = allLoans;
            _borrowedItems = allLoans.where((loan) => loan.borrowerId == id).toList();
            _lentItems = allLoans.where((loan) => loan.ownerId == id).toList();
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _userId = null;
            _loans = [];
            _borrowedItems = [];
            _lentItems = [];
            _loading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading loans: $e');
      if (mounted) {
        setState(() {
          _loans = [];
          _borrowedItems = [];
          _lentItems = [];
          _loading = false;
        });
      }
    }
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

  Widget _buildLoansContent() {
    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF87AE73),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Borrowed Items Section
            if (_borrowedItems.isNotEmpty) ...[
              _buildSectionHeader('Items I\'m Borrowing', _borrowedItems.length),
              const SizedBox(height: 12),
              ..._borrowedItems.map((loan) => _buildLoanCard(loan, isBorrowed: true)),
              const SizedBox(height: 24),
            ],
            
            // Lent Items Section
            if (_lentItems.isNotEmpty) ...[
              _buildSectionHeader('Items I\'ve Lent', _lentItems.length),
              const SizedBox(height: 12),
              ..._lentItems.map((loan) => _buildLoanCard(loan, isBorrowed: false)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF87AE73),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF87AE73),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoanCard(Loan loan, {required bool isBorrowed}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showLoanDetails(loan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Item Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF87AE73).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: loan.itemImagePath.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(loan.itemImagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            return const Center(
                              child: FaIcon(
                                FontAwesomeIcons.box,
                                color: Color(0xFF87AE73),
                                size: 24,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: FaIcon(
                          FontAwesomeIcons.box,
                          color: Color(0xFF87AE73),
                          size: 24,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              
              // Loan Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.itemName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBorrowed 
                          ? 'From: ${loan.ownerName}'
                          : 'To: ${loan.borrowerName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(loan.status),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            loan.statusDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (loan.isOverdue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'OVERDUE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Value and Arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'HB ${loan.itemValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF87AE73),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.active:
        return const Color(0xFF87AE73);
      case LoanStatus.completed:
        return Colors.blue;
      case LoanStatus.returned:
        return Colors.green;
      case LoanStatus.cancelled:
        return Colors.red;
    }
  }

  void _showLoanDetails(Loan loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loan.itemName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${loan.itemDescription}'),
            const SizedBox(height: 8),
            Text('Value: HB ${loan.itemValue.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Status: ${loan.statusDisplayName}'),
            const SizedBox(height: 8),
            Text('Start Date: ${_formatDate(loan.startDate)}'),
            if (loan.expectedReturnDate != null) ...[
              const SizedBox(height: 8),
              Text('Expected Return: ${_formatDate(loan.expectedReturnDate!)}'),
            ],
            if (loan.notes != null && loan.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${loan.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Loans'),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_userId == null)
          ? _buildLoginPrompt()
          : _loans.isEmpty
          ? _buildEmptyState()
          : _buildLoansContent(),
    );
  }
}
