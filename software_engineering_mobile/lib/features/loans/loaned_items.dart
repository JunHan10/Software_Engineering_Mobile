import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'new_item_page.dart';
import '../../core/services/auth_service.dart';
import '../../core/repositories/shared_prefs_user_repository.dart';
import '../../core/models/user.dart';

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
  bool _hasDraft = false;
  Map<String, dynamic> _draftData = {};

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
    await _loadDraft();
    if (!mounted) return;
    setState(() {
      _loanedItems = user?.assets ?? [];
      _loading = false;
    });
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftExists = prefs.getString('item_draft');
    if (draftExists != null) {
      setState(() {
        _hasDraft = true;
        _draftData = {
          'name': prefs.getString('draft_name') ?? '',
          'description': prefs.getString('draft_description') ?? '',
          'maintenance': prefs.getString('draft_maintenance') ?? '',
          'price': prefs.getDouble('draft_price') ?? 0.0,
        };
      });
    } else {
      setState(() {
        _hasDraft = false;
        _draftData = {};
      });
    }
  }

  Future<void> _deleteDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_name');
    await prefs.remove('draft_description');
    await prefs.remove('draft_maintenance');
    await prefs.remove('draft_price');
    await prefs.remove('item_draft');
    await _loadDraft();
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
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
                    FontAwesomeIcons.arrowUp,
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
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewItemPage(),
                      ),
                    );
                    if (result == true) {
                      await _loadItems();
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.plus),
                  label: const Text('Post Your First Item'),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightbulb,
                        color: Colors.blue[700],
                        size: 20,
                      ),
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
        ),
      ),
    );
  }

  Widget _buildDraftCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange[50],
      elevation: 3,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const FaIcon(FontAwesomeIcons.fileLines, color: Colors.orange),
        ),
        title: Row(
          children: [
            const Text('Draft', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'IN PROGRESS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          _draftData['name']?.isEmpty ?? true
              ? 'Unnamed item'
              : _draftData['name'],
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.trash, color: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Draft'),
                    content: const Text(
                      'Are you sure you want to delete this draft?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await _deleteDraft();
                }
              },
            ),
            const FaIcon(FontAwesomeIcons.chevronRight),
          ],
        ),
        onTap: () async {
          HapticFeedback.mediumImpact();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewItemPage()),
          );
          // Always refresh when coming back to check for draft changes
          await _loadItems();
        },
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _loanedItems.length + (_hasDraft ? 1 : 0),
      itemBuilder: (context, index) {
        // Show draft first if it exists
        if (_hasDraft && index == 0) {
          return _buildDraftCard();
        }

        // Adjust index for actual items if draft exists
        final itemIndex = _hasDraft ? index - 1 : index;
        final item = _loanedItems[itemIndex];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const FaIcon(FontAwesomeIcons.box),
            title: Text(item.name),
            subtitle: Text('HB ${item.value.toStringAsFixed(2)}'),
            trailing: const FaIcon(FontAwesomeIcons.chevronRight),
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
        title: const Text('Loan Assets'),
        backgroundColor: Color(0xFF87AE73),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadItems,
          color: const Color(0xFF87AE73),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _loanedItems.isEmpty && !_hasDraft
              ? _buildEmptyState(context)
              : _buildItemsList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewItemPage()),
          );
          // Always refresh when coming back to check for saved drafts
          await _loadItems();
        },
        backgroundColor: Color(0xFF87AE73),
        child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
      ),
    );
  }
}
