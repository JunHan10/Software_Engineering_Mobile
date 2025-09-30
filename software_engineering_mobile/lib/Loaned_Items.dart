import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_item_page.dart';

class Loaned_Items extends StatefulWidget {
  const Loaned_Items({super.key});

  @override
  State<Loaned_Items> createState() => _Loaned_ItemsState();
}

class _Loaned_ItemsState extends State<Loaned_Items> {
  List<dynamic> _loanedItems = []; // TODO: Replace with your actual item model
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    // TODO: Fetch user's loaned items from your data source
    // Example: _loanedItems = await itemRepository.getLoanedItemsByUserId(userId);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
    if (!mounted) return;
    setState(() {
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
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewItemPage()),
                );
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
        final _item = _loanedItems[index]; // ignore: unused_local_variable
        // TODO: Replace with your actual item widget
        // Example: return LoanedItemWidget(item: item);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.inventory),
            title: Text('Item #${index + 1}'), // TODO: Replace with item.name
            subtitle: Text('Status: Available'), // TODO: Replace with item.status
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
          final _result = await Navigator.push( // ignore: unused_local_variable
            context,
            MaterialPageRoute(builder: (context) => const NewItemPage()),
          );
          // TODO: Refresh the items list when returning from NewItemPage
          // if (_result == true) _loadItems();
        },
        backgroundColor: Color(0xFF87AE73),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}