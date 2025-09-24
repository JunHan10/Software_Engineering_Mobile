// lib/new_item_page.dart
//
// Add a new Asset to the CURRENTLY LOGGED-IN user.
// Only logic was updated to use AuthService.getCurrentUserId() and null-safe spreads.
// If you already have a custom UI for this page, keep your layout and copy just:
//   - _saveAsset()
//   - _loadCurrentUser()
//   - fields/controllers and imports

import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'repositories/shared_prefs_user_repository.dart';
import 'models/user.dart';

class NewItemPage extends StatefulWidget {
  const NewItemPage({super.key});

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final _nameCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _repo = SharedPrefsUserRepository();
  final _auth = AuthService();

  User? _currentUser;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userId = await _auth.getCurrentUserId();
    if (userId == null) {
      setState(() => _error = 'Please log in before adding items.');
      return;
    }
    final user = await _repo.findById(userId);
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _saveAsset() async {
    if (_saving) return;
    if (_currentUser == null) {
      setState(() => _error = 'No active user. Please log in.');
      return;
    }

    final name = _nameCtrl.text.trim();
    final value = double.tryParse(_valueCtrl.text.trim()) ?? 0.0;
    final desc = _descCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final newAsset = Asset(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        value: value,
        description: desc,
      );

      final user = _currentUser!;
      // Null-safe spread; if user.assets is null, it spreads nothing.
      final updated = _copyUser(
        user,
        assets: <Asset>[...?user.assets, newAsset],
      );

      await _repo.save(updated);
      if (!mounted) return;
      setState(() => _currentUser = updated);

      // Pop or show success — here we pop.
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = 'Failed to save item.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // Helper to avoid requiring a copyWith on your model
  User _copyUser(
      User u, {
        String? id,
        String? email,
        String? password,
        String? firstName,
        String? lastName,
        int? age,
        String? streetAddress,
        String? city,
        String? state,
        String? zipcode,
        double? currency,
        List<Asset>? assets,
        int? hippoBalanceCents,
      }) {
    return User(
      id: id ?? u.id,
      email: email ?? u.email,
      password: password ?? u.password,
      firstName: firstName ?? u.firstName,
      lastName: lastName ?? u.lastName,
      age: age ?? u.age,
      streetAddress: streetAddress ?? u.streetAddress,
      city: city ?? u.city,
      state: state ?? u.state,
      zipcode: zipcode ?? u.zipcode,
      currency: currency ?? u.currency,
      assets: assets ?? u.assets,
      // keep existing HB if present
      hippoBalanceCents: hippoBalanceCents ?? u.hippoBalanceCents,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Item name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valueCtrl,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: 'e.g. 299.99',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveAsset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87AE73),
                  foregroundColor: Colors.white,
                ),
                child: _saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
