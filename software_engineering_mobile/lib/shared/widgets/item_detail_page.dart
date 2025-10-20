// lib/shared/widgets/item_detail_page.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/services/category_service.dart';
import '../../core/services/comment_service.dart';
import '../../core/services/session_service.dart';
import '../../core/services/server_services.dart';
import '../../core/services/api_service.dart';
import '../../core/models/category.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {

  final _voteService = ServerVoteService();
  final _favoriteService = ServerFavoriteService();
  final _commentCtrl = TextEditingController();
  List<Comment> _comments = const [];
  bool _loading = true;
  int _voteScore = 0;
  int _myVote = 0; // -1, 0, 1
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _loadVotes();
    _loadFavoriteStatus();
  }

  Future<void> _loadComments() async {
    final list = await CommentService.getComments(widget.itemId);
    if (!mounted) return;
    setState(() {
      _comments = list;
      _loading = false;
    });
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final user = await SessionService.getCurrentUser();
    final authorId = user?.id ?? 'guest';
    final authorName = user != null
        ? '${user.firstName} ${user.lastName}'.trim()
        : 'Guest';
    final c = Comment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      itemId: widget.itemId,
      authorId: authorId,
      authorName: authorName.isEmpty ? 'Guest' : authorName,
      text: text,
      createdAt: DateTime.now(),
    );
    await CommentService.addComment(c);
    _commentCtrl.clear();
    await _loadComments();
  }

  Future<void> _loadVotes() async {
    final uid = await SessionService.getCurrentUserId() ?? 'guest';
    final score = await _voteService.getScore(widget.itemId);
    final my = await _voteService.getUserVote(widget.itemId, uid);
    if (!mounted) return;
    setState(() {
      _voteScore = score;
      _myVote = my;
    });
  }

  Future<void> _loadFavoriteStatus() async {
    final userId = await SessionService.getCurrentUserId() ?? 'guest';
    final isFavorited = await _favoriteService.isFavorited(widget.itemId, userId);
    if (!mounted) return;
    setState(() {
      _isFavorited = isFavorited;
    });
  }

  Future<void> _toggleFavorite() async {
    final userId = await SessionService.getCurrentUserId() ?? 'guest';
    await _favoriteService.toggleFavorite(
      itemId: widget.itemId,
      userId: userId,
    );
    if (!mounted) return;
    setState(() {
      _isFavorited = !_isFavorited;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorited ? 'Added to favorites!' : 'Removed from favorites!'),
      ),
    );
  }

  Future<Item?> _getItem() async {
    try {
      // Get all assets from database and find the matching one
      final assetsData = await ApiService.getAssets();
      
      for (final assetJson in assetsData) {
        if (assetJson['_id'] == widget.itemId) {
          // Get owner info
          final ownerData = await ApiService.getUserById(assetJson['ownerId']);
          final ownerName = ownerData != null 
              ? '${ownerData['firstName'] ?? ''} ${ownerData['lastName'] ?? ''}'.trim()
              : 'Unknown Owner';
          
          // Convert to Item
          return Item(
            id: assetJson['_id'] ?? '',
            name: assetJson['name'] ?? '',
            description: assetJson['description'] ?? '',
            price: (assetJson['value'] ?? 0).toDouble(),
            currency: 'HB',
            icon: Icons.inventory,
            imageUrl: (assetJson['imagePaths'] as List?)?.isNotEmpty == true 
                ? assetJson['imagePaths'][0] : '',
            categoryId: 'database-item',
            ownerId: assetJson['ownerId'] ?? '',
            ownerName: ownerName,
            isAvailable: true,
            tags: [],
          );
        }
      }
      
      // Fallback to CategoryService for hardcoded items
      return CategoryService.getItemById(widget.itemId);
    } catch (e) {
      print('Error loading item: $e');
      return null;
    }
  }

  Future<Item?> _findUserCreatedItem(String itemId) async {
    try {
      // Get current user's assets only for now
      final currentUser = await SessionService.getCurrentUser();
      if (currentUser == null) return null;
      
      for (final asset in currentUser.assets) {
        if (asset.id == itemId) {
          // Convert Asset to Item
          return Item(
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
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _toggleVote(int desired) async {
    final uid = await SessionService.getCurrentUserId() ?? 'guest';
    final current = await _voteService.getUserVote(widget.itemId, uid);
    final next = current == desired ? 0 : desired;
    final newScore = await _voteService.setVote(
      itemId: widget.itemId,
      userId: uid,
      vote: next,
    );
    if (!mounted) return;
    setState(() {
      _myVote = next;
      _voteScore = newScore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Item?>(
      future: _getItem(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final item = snapshot.data;
        if (item == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Item Not Found'),
              backgroundColor: const Color(0xFF87AE73),
              foregroundColor: Colors.white,
            ),
            body: const Center(child: Text('Item not found')),
          );
        }

        final category = CategoryService.getCategoryById(item.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: category != null
            ? Color(int.parse(category.color.replaceAll('#', '0xFF')))
            : const Color(0xFF87AE73),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image placeholder
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],
              child: Icon(item.icon, size: 100, color: Colors.grey[400]),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Price display removed
                    ],
                  ),

                  const SizedBox(height: 8),

                  const SizedBox(height: 16),

                  // Owner info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          item.ownerName[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Owner',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            item.ownerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              FontAwesomeIcons.arrowUp,
                              color: _myVote == 1
                                  ? (category != null
                                        ? Color(
                                            int.parse(
                                              category.color.replaceAll(
                                                '#',
                                                '0xFF',
                                              ),
                                            ),
                                          )
                                        : const Color(0xFF87AE73))
                                  : Colors.grey[500],
                              size: 20,
                            ),
                            onPressed: () => _toggleVote(1),
                            tooltip: 'Upvote',
                          ),
                          FutureBuilder<int>(
                            future: _voteService.getScore(widget.itemId),
                            builder: (context, snapshot) {
                              final s = snapshot.data ?? _voteScore;
                              return Text(
                                s.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: category != null
                                      ? Color(
                                          int.parse(
                                            category.color.replaceAll(
                                              '#',
                                              '0xFF',
                                            ),
                                          ),
                                        )
                                      : const Color(0xFF87AE73),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              FontAwesomeIcons.arrowDown,
                              color: _myVote == -1
                                  ? (category != null
                                        ? Color(
                                            int.parse(
                                              category.color.replaceAll(
                                                '#',
                                                '0xFF',
                                              ),
                                            ),
                                          )
                                        : const Color(0xFF87AE73))
                                  : Colors.grey[500],
                              size: 20,
                            ),
                            onPressed: () => _toggleVote(-1),
                            tooltip: 'Downvote',
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tags
                  const Text(
                    'Tags',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement contact owner functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Contact owner functionality coming soon!',
                                ),
                              ),
                            );
                          },
                          icon: const FaIcon(FontAwesomeIcons.message),
                          label: const Text('Borrow'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: category != null
                                ? Color(
                                    int.parse(
                                      category.color.replaceAll('#', '0xFF'),
                                    ),
                                  )
                                : const Color(0xFF87AE73),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleFavorite,
                          icon: FaIcon(
                            _isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                          ),
                          label: Text(_isFavorited ? 'Favorited' : 'Favorite'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: category != null
                                ? Color(
                                    int.parse(
                                      category.color.replaceAll('#', '0xFF'),
                                    ),
                                  )
                                : const Color(0xFF87AE73),
                            side: BorderSide(
                              color: category != null
                                  ? Color(
                                      int.parse(
                                        category.color.replaceAll('#', '0xFF'),
                                      ),
                                    )
                                  : const Color(0xFF87AE73),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Comments Section
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No comments yet. Be the first to comment!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final c = _comments[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                (c.authorName.isNotEmpty
                                        ? c.authorName[0]
                                        : 'G')
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        c.authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        _formatTime(c.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(c.text),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          minLines: 1,
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submitComment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: category != null
                              ? Color(
                                  int.parse(
                                    category.color.replaceAll('#', '0xFF'),
                                  ),
                                )
                              : const Color(0xFF87AE73),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        child: const Text('Post'),
                      ),
                    ],
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
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
