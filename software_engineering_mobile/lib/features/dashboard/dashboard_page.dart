// lib/features/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/services/notification_service.dart';

// Screens
import '../../shared/widgets/item_detail_page.dart';

// Models & Services
import '../../core/models/category.dart';
import '../../core/services/category_service.dart';
import '../../core/repositories/shared_prefs_user_repository.dart';
import '../../core/services/money_service.dart';
import '../../core/services/vote_service.dart';
import '../../core/services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repo = SharedPrefsUserRepository();
  final _auth = AuthService();
  int _hippoBalanceCents = 0;

  // -----------------------------------------------------------------------
  // PHASE: Search functionality
  // -----------------------------------------------------------------------
  final TextEditingController _searchController = TextEditingController();
  List<Item> _filteredItems = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    NotificationService.requestPermissionOnce();

    _loadBalance();
    _searchController.addListener(_onSearchChanged);
    _filteredItems = CategoryService.getAllItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // PHASE: Search Handler
  // -----------------------------------------------------------------------
  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredItems = CategoryService.searchItems(query);
      } else {
        _filteredItems = CategoryService.getAllItems();
      }
    });
  }

  // -----------------------------------------------------------------------
  // PHASE: Vote Row for Item
  // -----------------------------------------------------------------------
  Future<Widget> _voteRowForItem(Item item, Color accent) async {
    final userId = await _auth.getCurrentUserId() ?? 'guest';
    final score = await VoteService.getScore(item.id);
    final myVote = await VoteService.getUserVote(item.id, userId);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowUp,
            color: myVote == 1 ? accent : Colors.grey[500],
            size: 20,
          ),
          onPressed: () async {
            final current = await VoteService.getUserVote(item.id, userId);
            final next = current == 1 ? 0 : 1;
            await VoteService.setVote(
              itemId: item.id,
              userId: userId,
              vote: next,
            );
            if (!mounted) return;
            setState(() {});
          },
        ),
        FutureBuilder<int>(
          future: VoteService.getScore(item.id),
          builder: (context, snapshot) {
            final s = snapshot.data ?? score;
            return Text(
              s.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, color: accent),
            );
          },
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowDown,
            color: myVote == -1 ? accent : Colors.grey[500],
            size: 20,
          ),
          onPressed: () async {
            final current = await VoteService.getUserVote(item.id, userId);
            final next = current == -1 ? 0 : -1;
            await VoteService.setVote(
              itemId: item.id,
              userId: userId,
              vote: next,
            );
            if (!mounted) return;
            setState(() {});
          },
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // PHASE: Load Balance
  // -----------------------------------------------------------------------
  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('activeUserId');
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      setState(() => _hippoBalanceCents = 0);
      return;
    }
    final bal = await _repo.getHippoBalanceCents(userId);
    if (!mounted) return;
    setState(() => _hippoBalanceCents = bal);
  }

  // -----------------------------------------------------------------------
  // PHASE: Build Method
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF87AE73),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF87AE73),
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ),
            child: Text(
              MoneyService.formatCents(_hippoBalanceCents),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
              // -----------------------------------------------------------------------
              // SECTION: Search Bar
              // -----------------------------------------------------------------------
              TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  hintText: 'Search items...',
                  prefixIcon: Container(
                    width: 48,
                    alignment: Alignment.center,
                    child: const FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 18,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const FaIcon(FontAwesomeIcons.xmark, size: 18),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF87AE73),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // -----------------------------------------------------------------------
              // SECTION: Items Grid
              // -----------------------------------------------------------------------
              Expanded(child: _buildItemsGrid()),
            ],
        ),
      ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // SECTION: Items Grid Builder
  // -----------------------------------------------------------------------
  Widget _buildItemsGrid() {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No items found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching for something else',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width >= 900
            ? 4
            : width >= 600
            ? 3
            : 2;

        return GridView.builder(
          itemCount: _filteredItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final item = _filteredItems[index];
            const Color itemColor = Color(0xFF87AE73);

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailPage(itemId: item.id),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        color: itemColor.withOpacity(0.06),
                        child: item.imageUrl.isNotEmpty
                            ? Image.network(
                                item.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) {
                                  return Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.box,
                                      size: 40,
                                      color: itemColor,
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: FaIcon(
                                  FontAwesomeIcons.box,
                                  size: 40,
                                  color: itemColor,
                                ),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                item.formattedPrice,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: itemColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: FutureBuilder<Widget>(
                                      future: _voteRowForItem(item, itemColor),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                            width: 48,
                                            height: 20,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        }
                                        return snapshot.data ??
                                            const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.ownerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
