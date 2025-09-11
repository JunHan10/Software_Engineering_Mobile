import 'package:flutter/material.dart';

// Keep: your existing model + repo imports
import 'models/user.dart';                       // existing model
import 'repositories/shared_prefs_user_repository.dart'; // using concrete repo here
import 'services/money_service.dart';            // formatter for Hippo Bucks

/**
 * ProfilePage - Displays and manages user profile information
 *
 * This screen shows account details and (now) Hippo Bucks balance with simple
 * add/spend actions. All existing comments and layout patterns are preserved.
 */
class ProfilePage extends StatefulWidget {
  // Made optional so callers like Dashboard can keep pushing ProfilePage()
  // without passing a user object yet. If provided, we use its name/id.
  final User? user; // optional

  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Simple concrete repository usage for local persistence
  final _repo = SharedPrefsUserRepository();

  // Hippo Bucks is stored in cents
  int _hippoBalanceCents = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    // If we don't have a user id, we can’t load/update balance.
    final userId = widget.user?.id;
    if (userId == null) {
      setState(() => _hippoBalanceCents = 0);
      return;
    }
    final bal = await _repo.getHippoBalanceCents(userId);
    if (!mounted) return;
    setState(() => _hippoBalanceCents = bal);
  }

  Future<void> _promptAndDeposit() async {
    final userId = widget.user?.id;
    if (userId == null) {
      _showNeedUserSnack();
      return;
    }
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Hippo Bucks'),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: 'HB '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final cents = MoneyService.parseToCents(c.text);
      await _repo.depositHippoCents(userId, cents);
      await _loadBalance();
    }
  }

  Future<void> _promptAndWithdraw() async {
    final userId = widget.user?.id;
    if (userId == null) {
      _showNeedUserSnack();
      return;
    }
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Spend Hippo Bucks'),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: 'HB '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Spend'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final cents = MoneyService.parseToCents(c.text);
      await _repo.withdrawHippoCents(userId, cents);
      await _loadBalance();
    }
  }

  void _showNeedUserSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No user available. Log in or navigate here with a user.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Top-of-page profile info — show fallback text if user is null
    final name =
    '${widget.user?.firstName ?? 'Profile'} ${widget.user?.lastName ?? ''}'
        .trim();
    final email = widget.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /**
             * Existing profile UI (name/email/etc.). Kept simple here —
             * preserve your existing sections and styling below this header.
             */
            Text(name, style: Theme.of(context).textTheme.headlineSmall),
            if (email.isNotEmpty) Text(email),

            const SizedBox(height: 24),

            // Hippo Bucks section — wallet display + actions
            Text('Hippo Bucks',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              MoneyService.formatCents(_hippoBalanceCents),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _promptAndDeposit,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
                OutlinedButton.icon(
                  onPressed: _promptAndWithdraw,
                  icon: const Icon(Icons.remove),
                  label: const Text('Spend'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /**
             * Continue with the rest of your profile widgets here:
             * - assets list
             * - edit buttons
             * - logout, etc.
             * Keep all original comments/styles intact.
             */
          ],
        ),
      ),
    );
  }
}
