import 'package:flutter/material.dart';
import '../services/money_service.dart';

class ProfileWallet extends StatelessWidget {
  final int balanceCents;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  const ProfileWallet({
    super.key,
    required this.balanceCents,
    required this.onDeposit,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hippo Bucks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              MoneyService.formatCents(balanceCents),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: onDeposit,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87AE73),
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onWithdraw,
                  icon: const Icon(Icons.remove),
                  label: const Text('Spend'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF87AE73),
                    side: const BorderSide(color: Color(0xFF87AE73)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


