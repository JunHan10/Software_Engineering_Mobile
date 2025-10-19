// lib/shared/widgets/asset_detail_page.dart
// this file defines the AssetDetailPage widget
// for viewing and editing asset details in the post/asset loaned 

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _imagePicker = ImagePicker();
  
  // Edit mode controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  bool _isEditing = false;
  bool _saving = false;
  String? _error;
  List<String> _images = [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserAndInitialize();
  }

  Future<void> _loadUserAndInitialize() async {
    final userId = await _auth.getCurrentUserId();
    if (userId == null) return;
    
    final user = await _repo.findById(userId);
    if (!mounted) return;
    
    setState(() {
      _currentUser = user;
      _nameController.text = widget.asset.name;
      _descriptionController.text = widget.asset.description;
      _priceController.text = widget.asset.value.toStringAsFixed(2);
      _images = List.from(widget.asset.imagePaths);
    });
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        // Cancel editing - restore original values
        _nameController.text = widget.asset.name;
        _descriptionController.text = widget.asset.description;
        _priceController.text = widget.asset.value.toStringAsFixed(2);
        _images = List.from(widget.asset.imagePaths);
        _error = null;
      }
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    if (_saving || _currentUser == null) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final priceText = _priceController.text.trim();

    if (name.isEmpty || description.isEmpty || priceText.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      setState(() => _error = 'Please enter a valid price');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      // Create updated asset
      final updatedAsset = Asset(
        id: widget.asset.id,
        name: name,
        value: price,
        description: description,
        imagePaths: _images,
      );

      // Update user's assets list
      final updatedAssets = _currentUser!.assets.map((asset) {
        return asset.id == widget.asset.id ? updatedAsset : asset;
      }).toList();

      final updatedUser = _copyUser(_currentUser!, assets: updatedAssets);
      
      await _repo.save(updatedUser);

      if (!mounted) return;
      setState(() {
        _currentUser = updatedUser;
        _isEditing = false;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asset updated successfully!'),
          backgroundColor: Color(0xFF87AE73),
        ),
      );

      // Return the updated asset to the previous screen
      Navigator.pop(context, updatedAsset);
      
    } catch (e) {
      setState(() {
        _error = 'Failed to save changes: $e';
        _saving = false;
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          final newImagePaths = pickedFiles.map((file) => file.path).toList();
          _images.addAll(newImagePaths);
          _images = _images.toSet().toList(); // Remove duplicates
        });
      }
    } catch (e) {
      setState(() => _error = 'Failed to pick images: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _images.add(pickedFile.path);
          _images = _images.toSet().toList(); // Remove duplicates
        });
      }
    } catch (e) {
      setState(() => _error = 'Failed to take photo: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _deleteAsset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: const Text('Are you sure you want to delete this asset? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || _currentUser == null) return;

    try {
      setState(() => _saving = true);

      // Remove asset from user's assets list
      final updatedAssets = _currentUser!.assets
          .where((asset) => asset.id != widget.asset.id)
          .toList();

      final updatedUser = _copyUser(_currentUser!, assets: updatedAssets);
      
      await _repo.save(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asset deleted successfully!'),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pop(context, 'deleted');
      
    } catch (e) {
      setState(() {
        _error = 'Failed to delete asset: $e';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
                            label: const Text('Borrow'),
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
=======
    const Color categoryColor = Color(0xFF87AE73);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Asset' : widget.asset.name),
        backgroundColor: categoryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing) ...[
            IconButton(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.edit),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteAsset();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Asset'),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            TextButton(
              onPressed: _toggleEditMode,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: _saving ? null : _saveChanges,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Error message
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red[50],
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _error = null),
                    icon: Icon(Icons.close, color: Colors.red[700]),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image header
                  Container(
                    height: 300,
                    width: double.infinity,
                    child: _images.isNotEmpty
                        ? PageView.builder(
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 300,
                                    child: Image.file(
                                      File(_images[index]),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.inventory,
                                            size: 100,
                                            color: Colors.grey[400],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Delete image button when editing
                                  if (_isEditing)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Image counter
                                  if (_images.length > 1)
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${index + 1}/${_images.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No image available',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),

                  // Content section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Price row
                        Row(
                          children: [
                            Expanded(
                              child: _isEditing
                                  ? TextField(
                                      controller: _nameController,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Asset Name',
                                        border: OutlineInputBorder(),
                                      ),
                                    )
                                  : Text(
                                      widget.asset.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: _isEditing
                                  ? SizedBox(
                                      width: 120,
                                      child: TextField(
                                        controller: _priceController,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: categoryColor,
                                        ),
                                        decoration: const InputDecoration(
                                          prefixText: 'HB ',
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'HB ${widget.asset.value.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: categoryColor,
                                      ),
                                    ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Owner info
                        if (_currentUser != null) ...[
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: categoryColor,
                                child: Text(
                                  _currentUser!.firstName.isNotEmpty 
                                      ? _currentUser!.firstName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Owner',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${_currentUser!.firstName} ${_currentUser!.lastName}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Row(
                                children: [
                                  Icon(Icons.keyboard_arrow_up, color: Colors.grey),
                                  Text('0', style: TextStyle(color: Colors.grey)),
                                  Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _isEditing
                            ? TextField(
                                controller: _descriptionController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                              )
                            : Text(
                                widget.asset.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  height: 1.5,
                                ),
                              ),

                        const SizedBox(height: 24),

                        // Tags
                        const Text(
                          'Tags',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildTag('asset'),
                            _buildTag('item'),
                            if (widget.asset.name.toLowerCase().contains('car'))
                              _buildTag('vehicle'),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Action buttons
                        if (!_isEditing) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Contact owner functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Contact owner feature coming soon!'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.chat),
                                  label: const Text('Borrow'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: categoryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // Favorite functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to favorites!'),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.favorite_border, color: categoryColor),
                                  label: Text('Favorite', style: TextStyle(color: categoryColor)),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: categoryColor),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Add photos buttons when editing
                        if (_isEditing) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickImages,
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Add from Gallery'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: categoryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickImageFromCamera,
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Take Photo'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: categoryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Comments section
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No comments yet. Be the first to comment!',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Comment input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Comment feature coming soon!'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: categoryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Post'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Helper to copy user with updated assets
  User _copyUser(
    User u, {
    String? id,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    int? age,
    String? streetAddress,
    String? city,
    String? state,
    String? zipcode,
    double? currency,
    List<Asset>? assets,
    int? hippoBalanceCents,
  }) {
    return User(
      id: id ?? u.id,
      email: email ?? u.email,
      password: password ?? u.password,
      firstName: firstName ?? u.firstName,
      lastName: lastName ?? u.lastName,
      age: age ?? u.age,
      streetAddress: streetAddress ?? u.streetAddress,
      city: city ?? u.city,
      state: state ?? u.state,
      zipcode: zipcode ?? u.zipcode,
      currency: currency ?? u.currency,
      assets: assets ?? u.assets,
      hippoBalanceCents: hippoBalanceCents ?? u.hippoBalanceCents,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
