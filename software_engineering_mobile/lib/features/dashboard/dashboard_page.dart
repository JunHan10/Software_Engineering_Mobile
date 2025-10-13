// lib/features/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/services/notification_service.dart';

// Screens
import '../../shared/widgets/item_detail_page.dart';

// Models & Services
import '../../core/models/category.dart';
import '../../core/services/category_service.dart';
import '../../core/services/vote_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/favorite_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _auth = AuthService();
  // int _hippoBalanceCents = 0;

  // -----------------------------------------------------------------------
  // PHASE: Search functionality
  // -----------------------------------------------------------------------
  final TextEditingController _searchController = TextEditingController();
  List<Item> _filteredItems = [];
  bool _isSearching = false;
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();

    NotificationService.requestPermissionOnce();

    // _loadBalance();
    _searchController.addListener(_onSearchChanged);
    _loadAllItems();
  }

  Future<void> _loadAllItems() async {
    final categoryItems = CategoryService.getAllItems();
    final userItems = await _getUserCreatedItems();
    setState(() {
      _filteredItems = [...categoryItems, ...userItems];
    });
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
      _updateFilteredItems();
    });
  }

  void _updateFilteredItems() async {
    List<Item> items;
    
    // Get items from CategoryService
    List<Item> categoryItems;
    if (_isSearching) {
      categoryItems = CategoryService.searchItems(_searchController.text);
    } else {
      categoryItems = CategoryService.getAllItems();
    }

    // Get user-created items
    List<Item> userItems = await _getUserCreatedItems();
    
    // Apply search to user items if searching
    if (_isSearching) {
      final query = _searchController.text.toLowerCase();
      userItems = userItems.where((item) => 
        item.name.toLowerCase().contains(query) ||
        item.description.toLowerCase().contains(query)
      ).toList();
    }
    
    // Combine both lists
    items = [...categoryItems, ...userItems];

    if (_showFavoritesOnly) {
      final userId = await _auth.getCurrentUserId() ?? 'guest';
      final favorites = await FavoriteService.getUserFavorites(userId);
      items = items.where((item) => favorites.contains(item.id)).toList();
    }

    setState(() {
      _filteredItems = items;
    });
  }

  Future<List<Item>> _getUserCreatedItems() async {
    try {
      // Get current user's assets only for now
      final currentUser = await _auth.getCurrentUser();
      if (currentUser == null) return [];
      
      List<Item> userItems = [];
      for (final asset in currentUser.assets) {
        // Convert Asset to Item for display
        final item = Item(
          id: asset.id ?? '',
          name: asset.name,
          description: asset.description,
          price: asset.value,
          currency: 'HB',
          icon: Icons.inventory,
          imageUrl: asset.imagePaths.isNotEmpty ? asset.imagePaths.first : '',
          categoryId: 'user-created',
          ownerId: currentUser.id ?? '',
          ownerName: '${currentUser.firstName} ${currentUser.lastName}'.trim(),
          isAvailable: true,
          tags: [],
        );
        userItems.add(item);
      }
      
      return userItems;
    } catch (e) {
      return [];
    }
  }

  Future<bool> _isItemFavorited(String itemId) async {
    final userId = await _auth.getCurrentUserId() ?? 'guest';
    return await FavoriteService.isFavorited(itemId, userId);
  }

  void _toggleFavoritesFilter() async {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
    });
    _updateFilteredItems();
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
  // Future<void> _loadBalance() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getString('activeUserId');
  //   if (userId == null || userId.isEmpty) {
  //     if (!mounted) return;
  //     setState(() => _hippoBalanceCents = 0);
  //     return;
  //   }
  //   final bal = await _repo.getHippoBalanceCents(userId);
  //   if (!mounted) return;
  //   setState(() => _hippoBalanceCents = bal);
  // }

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
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(
        //       vertical: 16.0,
        //       horizontal: 8.0,
        //     ),
        //     child: Text(
        //       MoneyService.formatCents(_hippoBalanceCents),
        //       style: const TextStyle(
        //         fontSize: 14,
        //         fontWeight: FontWeight.normal,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
              // -----------------------------------------------------------------------
              // SECTION: Search Bar with Heart Button
              // -----------------------------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: TextField(
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
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _showFavoritesOnly ? const Color(0xFF87AE73) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF87AE73),
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.heart,
                        color: _showFavoritesOnly ? Colors.white : const Color(0xFF87AE73),
                        size: 20,
                      ),
                      onPressed: _toggleFavoritesFilter,
                    ),
                  ),
                ],
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
              _showFavoritesOnly ? FontAwesomeIcons.heart : FontAwesomeIcons.magnifyingGlass,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _showFavoritesOnly ? 'No favorites yet' : 'No items found',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _showFavoritesOnly 
                ? 'Add items to your favorites to see them here'
                : 'Try searching for something else',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                      child: Stack(
                        children: [
                          Container(
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
                          // Favorite indicator
                          FutureBuilder<bool>(
                            future: _isItemFavorited(item.id),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data == true) {
                                return Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const FaIcon(
                                      FontAwesomeIcons.solidHeart,
                                      size: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
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
                              // Price display removed
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
