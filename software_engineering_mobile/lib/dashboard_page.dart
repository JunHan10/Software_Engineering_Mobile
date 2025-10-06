// lib/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
// Screens
import 'screens/category_detail_page.dart';
import 'screens/item_detail_page.dart';

// Models & Services
import 'models/category.dart';
import 'services/category_service.dart';
import 'repositories/shared_prefs_user_repository.dart';
import 'services/money_service.dart';
import 'services/vote_service.dart';
import 'services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repo = SharedPrefsUserRepository();
  final _auth = AuthService();
  int _hippoBalanceCents = 0;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  List<Category> _filteredCategories = [];
  List<Item> _filteredItems = [];
  bool _isSearching = false;

  // Category view state
  Category? _selectedCategory;
  List<Item> _filteredCategoryItems = [];
  final TextEditingController _categorySearchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    NotificationService.requestPermissionOnce();

    /*// Show immediate test notification
    Future.delayed(const Duration(seconds: 2), () {
      NotificationService.showNotification(
        id: 0,
        title: 'Welcome!',
        body: 'You opened the Dashboard 🎉',
      );
    });

    // Schedule daily reminder at 8:00 AM
    NotificationService.scheduleNotification(
      id: 1,
      title: 'Daily Reminder',
      body: 'Don\'t forget to check your dashboard!',
      hour: 8,
      minute: 0,
    );*/
    _loadBalance();
    _searchController.addListener(_onSearchChanged);
    _categorySearchController.addListener(_onCategorySearchChanged);
    _filteredCategories = CategoryService.getAllCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredCategories = CategoryService.searchCategories(query);
        _filteredItems = CategoryService.searchItems(query);
        _selectedCategory = null; // Clear category view when searching
      } else {
        _filteredCategories = CategoryService.getAllCategories();
        _filteredItems = [];
        _selectedCategory = null; // Clear category view when not searching
      }
    });
  }

  void _onCategorySearchChanged() {
    if (_selectedCategory != null) {
      final query = _categorySearchController.text;
      setState(() {
        if (query.isEmpty) {
          _filteredCategoryItems = _selectedCategory!.items;
        } else {
          _filteredCategoryItems = _selectedCategory!.items.where((item) {
            final lowercaseQuery = query.toLowerCase();
            return item.name.toLowerCase().contains(lowercaseQuery) ||
                item.description.toLowerCase().contains(lowercaseQuery) ||
                item.tags.any(
                  (tag) => tag.toLowerCase().contains(lowercaseQuery),
                );
          }).toList();
        }
      });
    }
  }

  void _selectCategory(Category category) {
    setState(() {
      _selectedCategory = category;
      _filteredCategoryItems = category.items;
      _categorySearchController.clear();
    });
  }

  Future<Widget> _voteRowForItem(Item item, Color accent) async {
    final userId = await _auth.getCurrentUserId() ?? 'guest';
    final score = await VoteService.getScore(item.id);
    final myVote = await VoteService.getUserVote(item.id, userId);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_upward,
              color: myVote == 1 ? accent : Colors.grey[500], size: 20),
          onPressed: () async {
            final current = await VoteService.getUserVote(item.id, userId);
            final next = current == 1 ? 0 : 1;
            await VoteService.setVote(itemId: item.id, userId: userId, vote: next);
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
          icon: Icon(Icons.arrow_downward,
              color: myVote == -1 ? accent : Colors.grey[500], size: 20),
          onPressed: () async {
            final current = await VoteService.getUserVote(item.id, userId);
            final next = current == -1 ? 0 : -1;
            await VoteService.setVote(itemId: item.id, userId: userId, vote: next);
            if (!mounted) return;
            setState(() {});
          },
        ),
      ],
    );
  }

  void _goBackToCategories() {
    setState(() {
      _selectedCategory = null;
      _filteredCategoryItems = [];
      _categorySearchController.clear();
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _selectedCategory != null
                    ? _categorySearchController
                    : _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  hintText: _selectedCategory != null
                      ? 'Search within ${_selectedCategory!.name}...'
                      : 'Search categories and items...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon:
                      (_selectedCategory != null
                              ? _categorySearchController
                              : _searchController)
                          .text
                          .isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            if (_selectedCategory != null) {
                              _categorySearchController.clear();
                            } else {
                              _searchController.clear();
                            }
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _selectedCategory != null
                          ? Color(
                              int.parse(
                                _selectedCategory!.color.replaceAll(
                                  '#',
                                  '0xFF',
                                ),
                              ),
                            )
                          : const Color(0xFF87AE73),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Content based on current view state
              Expanded(
                child: _selectedCategory != null
                    ? _buildCategoryView()
                    : _isSearching
                    ? _buildSearchResults()
                    : _buildCategoriesGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryView() {
    if (_selectedCategory == null) return const SizedBox.shrink();

    final category = _selectedCategory!;
    final categoryColor = Color(
      int.parse(category.color.replaceAll('#', '0xFF')),
    );

    return Column(
      children: [
        // Category header with back button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: categoryColor.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _goBackToCategories,
                icon: const Icon(Icons.arrow_back),
                color: categoryColor,
              ),
              const SizedBox(width: 8),
              Icon(category.icon, size: 32, color: categoryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_filteredCategoryItems.length} items',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Items grid
        Expanded(
          child: _filteredCategoryItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No items found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    final int crossAxisCount = width >= 900
                        ? 4
                        : width >= 600
                            ? 3
                            : 2;

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCategoryItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final item = _filteredCategoryItems[index];
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
                                  builder: (context) =>
                                      ItemDetailPage(itemId: item.id),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    color: categoryColor.withOpacity(0.06),
                                    child: item.imageUrl.isNotEmpty
                                        ? Image.network(
                                            item.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stack) {
                                              return Center(
                                                child: Icon(
                                                  item.icon,
                                                  size: 40,
                                                  color: categoryColor,
                                                ),
                                              );
                                            },
                                          )
                                        : Center(
                                            child: Icon(
                                              item.icon,
                                              size: 40,
                                              color: categoryColor,
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
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: categoryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: FutureBuilder<Widget>(
                                                  future: _voteRowForItem(item, categoryColor),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return const SizedBox(
                                                        width: 48,
                                                        height: 20,
                                                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                      );
                                                    }
                                                    return snapshot.data ?? const SizedBox.shrink();
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
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];
        final categoryColor = Color(
          int.parse(category.color.replaceAll('#', '0xFF')),
        );

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _selectCategory(category),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    categoryColor.withOpacity(0.1),
                    categoryColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category.icon, size: 48, color: categoryColor),
                    const SizedBox(height: 12),
                    Flexible(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category.items.length} items',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return ListView(
      children: [
        // Categories section
        if (_filteredCategories.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ..._filteredCategories.map((category) {
            final categoryColor = Color(
              int.parse(category.color.replaceAll('#', '0xFF')),
            );
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: categoryColor.withOpacity(0.1),
                  child: Icon(category.icon, color: categoryColor),
                ),
                title: Text(category.name),
                subtitle: Text('${category.items.length} items'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CategoryDetailPage(categoryId: category.id),
                    ),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Items section
        if (_filteredItems.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final int crossAxisCount = width >= 900
                  ? 4
                  : width >= 600
                      ? 3
                      : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final category = CategoryService.getCategoryById(item.categoryId);
                  final Color categoryColor = category != null
                      ? Color(int.parse(category.color.replaceAll('#', '0xFF')))
                      : const Color(0xFF87AE73);

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
                              color: categoryColor.withOpacity(0.06),
                              child: item.imageUrl.isNotEmpty
                                  ? Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) {
                                        return Center(
                                          child: Icon(
                                            item.icon,
                                            size: 40,
                                            color: categoryColor,
                                          ),
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Icon(
                                        item.icon,
                                        size: 40,
                                        color: categoryColor,
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
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: categoryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: FutureBuilder<Widget>(
                                            future: _voteRowForItem(item, categoryColor),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const SizedBox(
                                                  width: 48,
                                                  height: 20,
                                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                );
                                              }
                                              return snapshot.data ?? const SizedBox.shrink();
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
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
          ),
        ],

        // No results message
        if (_filteredCategories.isEmpty && _filteredItems.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try searching for something else',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
