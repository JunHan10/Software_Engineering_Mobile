// lib/screens/item_detail_page.dart

import 'package:flutter/material.dart';
import '../services/category_service.dart';

class ItemDetailPage extends StatelessWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final item = CategoryService.getItemById(itemId);

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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: category != null
                              ? Color(
                                  int.parse(
                                    category.color.replaceAll('#', '0xFF'),
                                  ),
                                ).withOpacity(0.1)
                              : const Color(0xFF87AE73).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.formattedPrice,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: category != null
                                ? Color(
                                    int.parse(
                                      category.color.replaceAll('#', '0xFF'),
                                    ),
                                  )
                                : const Color(0xFF87AE73),
                          ),
                        ),
                      ),
                    ],
                  ),

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
                          icon: const Icon(Icons.message),
                          label: const Text('Contact Owner'),
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
                          onPressed: () {
                            // TODO: Implement favorite functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to favorites!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.favorite_border),
                          label: const Text('Favorite'),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
