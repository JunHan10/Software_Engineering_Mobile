import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/models/user.dart';

/// Posts section widget for ProfileV2
/// Displays user's created posts/items in grid layout with expandable view
class PostsSection extends StatefulWidget {
  final List<Asset> userPosts;
  final VoidCallback onCreatePost;
  final void Function(Asset post) onPostTap;

  const PostsSection({
    super.key,
    required this.userPosts,
    required this.onCreatePost,
    required this.onPostTap,
  });

  @override
  State<PostsSection> createState() => _PostsSectionState();
}

class _PostsSectionState extends State<PostsSection> {
  bool _isExpanded = false;
  static const int _initialItemCount = 2; // Show first 4 posts (2 rows)

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildPostsContent(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Posts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF87AE73),
          ),
        ),
        TextButton.icon(
          onPressed: widget.onCreatePost,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Create Post'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF87AE73),
          ),
          onPressed: onAddImages,
          icon: const FaIcon(FontAwesomeIcons.images, size: 18),
          label: const Text('Add Photos'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF87AE73)),
        ),
      ],
    );
  }

  Widget _buildPostsContent() {
    if (widget.userPosts.isEmpty) {
      return _buildEmptyPosts();
    }
    return Column(
      children: [
        _buildPostsList(),
        if (widget.userPosts.length > _initialItemCount && !_isExpanded)
          _buildViewMoreButton(),
      ],
    );
  }

  Widget _buildEmptyPosts() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          style: BorderStyle.solid,
        ),
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_outlined, 
              color: Colors.grey, 
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No posts yet', 
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            FaIcon(FontAwesomeIcons.images, color: Colors.grey, size: 32),
            SizedBox(height: 8),
            Text(
              'Create your first post to get started!', 
              style: TextStyle(
                color: Colors.grey, 
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    final displayCount = _isExpanded ? widget.userPosts.length : 
        (widget.userPosts.length > _initialItemCount ? _initialItemCount : widget.userPosts.length);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.50,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        final post = widget.userPosts[index];
        const Color categoryColor = Color(0xFF87AE73);
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => widget.onPostTap(post),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image header - larger for dashboard style
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    color: categoryColor.withOpacity(0.1),
                    child: post.imagePaths.isNotEmpty
                        ? Image.file(
                            File(post.imagePaths.first),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) {
                              return Center(
                                child: Icon(
                                  Icons.inventory,
                                  size: 40,
                                  color: categoryColor,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.inventory,
                              size: 40,
                              color: categoryColor,
                            ),
                          ),
                  ),
                ),
                
                // Content section - dashboard style
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Asset name
                        Text(
                          post.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Description (if available)
                        if (post.description.isNotEmpty)
                          Text(
                            post.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        
                        const Spacer(),
                        
                        // Price section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'HB ${post.value.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Arrow icon like in dashboard
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ],
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(images[index]),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onRemoveImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.xmark,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF87AE73),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View More',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
