import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/models/user.dart';
import '../../core/services/auth_service.dart';
import '../../core/repositories/shared_prefs_user_repository.dart';

class AssetDetailPage extends StatefulWidget {
  final Asset asset;

  const AssetDetailPage({super.key, required this.asset});

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  final _auth = AuthService();
  final _repo = SharedPrefsUserRepository();
  late Asset _asset;
  bool _isOwner = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _asset = widget.asset;
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    final userId = await _auth.getCurrentUserId();
    if (userId != null) {
      final user = await _repo.findById(userId);
      if (user != null) {
        setState(() {
          _isOwner = user.assets.any((asset) => asset.id == _asset.id);
          _loading = false;
        });
      }
    } else {
      setState(() {
        _isOwner = false;
        _loading = false;
      });
    }
  }

  Future<void> _deleteAsset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: const Text(
          'Are you sure you want to delete this asset? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final userId = await _auth.getCurrentUserId();
      if (userId != null) {
        final user = await _repo.findById(userId);
        if (user != null) {
          final updatedAssets = user.assets.where((asset) => asset.id != _asset.id).toList();
          final updatedUser = user.copyWith(assets: updatedAssets);
          await _repo.save(updatedUser);
          
          if (mounted) {
            Navigator.pop(context, true); // Return true to indicate deletion
          }
        }
      }
    }
  }

  Future<void> _editAsset() async {
    // Navigate to edit page (you might need to create this)
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_asset.name),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
        actions: _isOwner
            ? [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.penToSquare),
                  onPressed: _editAsset,
                  tooltip: 'Edit Asset',
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.trash),
                  onPressed: _deleteAsset,
                  tooltip: 'Delete Asset',
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset image
            Container(
              width: double.infinity,
              height: 300,
              color: const Color(0xFF87AE73).withOpacity(0.1),
              child: _asset.imagePaths.isNotEmpty
                  ? Image.file(
                      File(_asset.imagePaths.first),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        return Center(
                          child: FaIcon(
                            FontAwesomeIcons.box,
                            size: 80,
                            color: const Color(0xFF87AE73),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: FaIcon(
                        FontAwesomeIcons.box,
                        size: 80,
                        color: const Color(0xFF87AE73),
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asset name and value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _asset.name,
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
                          color: const Color(0xFF87AE73).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'HB ${_asset.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF87AE73),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Owner info (if not the current user)
                  if (!_isOwner) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: const FaIcon(
                            FontAwesomeIcons.user,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Owner',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Asset Owner',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _asset.description.isNotEmpty
                        ? _asset.description
                        : 'No description provided.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Asset details
                  const Text(
                    'Asset Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Asset ID', _asset.id ?? 'Not assigned'),
                        const Divider(),
                        _buildDetailRow('Value', 'HB ${_asset.value.toStringAsFixed(2)}'),
                        const Divider(),
                        _buildDetailRow('Images', '${_asset.imagePaths.length} image(s)'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  if (_isOwner) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _editAsset,
                            icon: const FaIcon(FontAwesomeIcons.penToSquare),
                            label: const Text('Edit Asset'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF87AE73),
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
                            onPressed: _deleteAsset,
                            icon: const FaIcon(FontAwesomeIcons.trash),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Contact owner functionality coming soon!'),
                                ),
                              );
                            },
                            icon: const FaIcon(FontAwesomeIcons.message),
                            label: const Text('Contact Owner'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF87AE73),
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
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to favorites!'),
                                ),
                              );
                            },
                            icon: const FaIcon(FontAwesomeIcons.heart),
                            label: const Text('Favorite'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF87AE73),
                              side: const BorderSide(color: Color(0xFF87AE73)),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
