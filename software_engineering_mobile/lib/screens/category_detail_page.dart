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

          // Items grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final int crossAxisCount = width >= 900
                    ? 4
                    : width >= 600
                        ? 3
                        : 2;
                final Color categoryColor = Color(
                  int.parse(category.color.replaceAll('#', '0xFF')),
                );

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: category.items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final item = category.items[index];
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
                            // Image header
                            AspectRatio(
                              aspectRatio: 16 / 12,
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
                            // Text content
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.formattedPrice,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: categoryColor,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          item.ownerName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
