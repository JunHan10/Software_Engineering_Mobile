import 'dart:io';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class ActiveLoans extends StatelessWidget {
  const ActiveLoans({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Loans'),
        backgroundColor: Color(0xFF87AE73),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: user == null
              ? const Center(child: Text('Please log in to view active listings'))
              : (user.assets.isEmpty
                  ? const Center(child: Text('No active listings'))
                  : ListView.separated(
                      itemCount: user.assets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final asset = user.assets[index];
                        final hasImage = asset.imagePaths.isNotEmpty;
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: hasImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(asset.imagePaths.first),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.image_not_supported),
                            title: Text(asset.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(asset.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: Text('\$${asset.value.toStringAsFixed(2)}'),
                          ),
                        );
                      },
                    )),
        ),
      ),
    );
  }
}