import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_item_page.dart';
import 'services/auth_service.dart';
import 'repositories/shared_prefs_user_repository.dart';
import 'models/user.dart';

class Loaned_Items extends StatefulWidget {
  const Loaned_Items({super.key});

  @override
  State<Loaned_Items> createState() => _Loaned_ItemsState();
}

class _Loaned_ItemsState extends State<Loaned_Items> {
  final _auth = AuthService();
  final _repo = SharedPrefsUserRepository();
  List<Asset> _loanedItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    final userId = await _auth.getCurrentUserId();
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _loanedItems = [];
        _loading = false;
      });
      return;
    }
    final user = await _repo.findById(userId);
    if (!mounted) return;
    setState(() {
      _loanedItems = user?.assets ?? [];
      _loading = false;
    });
  }

  Widget _buildEmptyState(BuildContext context) {
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
                Icons.upload_outlined,
                size: 80,
                color: const Color(0xFF87AE73),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Items Posted Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start earning Hippo Bucks by lending your unused items!\nPost your first item to get started.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewItemPage()),
                );
                if (result == true) {
                  await _loadItems();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Post Your First Item'),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Popular items to lend: Electronics, Sports equipment, Books, Tools',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _loanedItems.length,
      itemBuilder: (context, index) {
        final item = _loanedItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.inventory),
            title: Text(item.name),
            subtitle: Text('HB ${item.value.toStringAsFixed(2)}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to item details or edit
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ItemDetailsPage(item: item)));
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
        title: const Text('Loaned Assets'),
        backgroundColor: Color(0xFF87AE73),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loanedItems.isEmpty
            ? _buildEmptyState(context)
            : _buildItemsList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewItemPage()),
          );
          if (result == true) {
            await _loadItems();
          }
        },
        backgroundColor: Color(0xFF87AE73),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}