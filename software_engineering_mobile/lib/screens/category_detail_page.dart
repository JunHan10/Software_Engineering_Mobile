// lib/screens/category_detail_page.dart

import 'package:flutter/material.dart';
import '../services/category_service.dart';
import 'item_detail_page.dart';

class CategoryDetailPage extends StatelessWidget {
  final String categoryId;

  const CategoryDetailPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final category = CategoryService.getCategoryById(categoryId);

    if (category == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Category Not Found'),
          backgroundColor: const Color(0xFF87AE73),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Category not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: Color(
          int.parse(category.color.replaceAll('#', '0xFF')),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Category header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(
                int.parse(category.color.replaceAll('#', '0xFF')),
              ).withOpacity(0.1),
            ),
            child: Column(
              children: [
                Icon(
                  category.icon,
                  size: 64,
                  color: Color(
                    int.parse(category.color.replaceAll('#', '0xFF')),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.description,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '${category.items.length} items available',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: category.items.length,
              itemBuilder: (context, index) {
                final item = category.items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailPage(itemId: item.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                  category.color.replaceAll('#', '0xFF'),
                                ),
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              item.icon,
                              size: 30,
                              color: Color(
                                int.parse(
                                  category.color.replaceAll('#', '0xFF'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.formattedPrice,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(
                                          int.parse(
                                            category.color.replaceAll(
                                              '#',
                                              '0xFF',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'by ${item.ownerName}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
