// lib/new_item_page.dart
//
// Multi-step item creation page with draft saving functionality
// Features: 5-step process, quit confirmation, draft saving, process visual

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import '../../core/services/session_service.dart';
import '../../core/services/api_service.dart';
import '../../core/models/user.dart';

class NewItemPage extends StatefulWidget {
  const NewItemPage({super.key});

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  // ---- Controllers ----
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _maintenanceCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  // ---- State Management ----

  final _imagePicker = ImagePicker();

  User? _currentUser;
  bool _saving = false;
  String? _error;

  // ---- Multi-step Form State ----
  int _currentStep = 0;
  final List<String> _stepTitles = [
    'Name',
    'Description',
    'Pictures',
    'Price',
    'Review',
  ];
  List<String> _images = [];

  // ---- Form Data ----
  String _itemName = '';
  String _description = '';
  String _maintenance = '';
  double _price = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadDraft();
  }

  // ---- Phase 1: Initialization ----
  Future<void> _loadCurrentUser() async {
    final user = await SessionService.getCurrentUser();
    if (user == null) {
      setState(() => _error = 'Please log in before adding items.');
      return;
    }
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  // ---- Phase 2: Draft Management ----
  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftData = prefs.getString('item_draft');
    if (draftData != null) {
      // Parse draft data and populate fields
      // For now, we'll implement basic draft loading
      setState(() {
        _itemName = prefs.getString('draft_name') ?? '';
        _description = prefs.getString('draft_description') ?? '';
        _maintenance = prefs.getString('draft_maintenance') ?? '';
        _price = prefs.getDouble('draft_price') ?? 0.0;

        _nameCtrl.text = _itemName;
        _descCtrl.text = _description;
        _maintenanceCtrl.text = _maintenance;
        _priceCtrl.text = _price > 0 ? _price.toString() : '';
      });
    }
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_name', _itemName);
    await prefs.setString('draft_description', _description);
    await prefs.setString('draft_maintenance', _maintenance);
    await prefs.setDouble('draft_price', _price);
    await prefs.setString('item_draft', 'exists');
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_name');
    await prefs.remove('draft_description');
    await prefs.remove('draft_maintenance');
    await prefs.remove('draft_price');
    await prefs.remove('item_draft');
  }

  // ---- Phase 3: Navigation Methods ----
  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _stepTitles.length - 1) {
        setState(() => _currentStep++);
        _updateFormData();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _goToStep(int step) {
    if (step >= 0 && step < _stepTitles.length) {
      setState(() => _currentStep = step);
    }
  }

  void _updateFormData() {
    setState(() {
      _itemName = _nameCtrl.text.trim();
      _description = _descCtrl.text.trim();
      _maintenance = _maintenanceCtrl.text.trim();
      _price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    });
    _saveDraft(); // Auto-save draft as user progresses
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Name
        if (_nameCtrl.text.trim().isEmpty) {
          setState(() => _error = 'Item name is required');
          return false;
        }
        break;
      case 1: // Description & Maintenance
        if (_descCtrl.text.trim().isEmpty) {
          setState(() => _error = 'Description is required');
          return false;
        }
        break;
      case 2: // Pictures
        if (_images.isEmpty) {
          setState(() => _error = 'At least one photo is required');
          return false;
        }
        break;
      case 3: // Price
        // Price is now optional - no validation required
        break;
    }
    setState(() => _error = null);
    return true;
  }

  // ---- Phase 3.5: Photo Picker Methods ----
  Future<void> _pickImages() async {
    try {
      // Use pickMultiImage which allows multiple selection
      // Note: The native picker will show checkmarks for already selected images
      // if the user has previously selected them in the same session
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          // Add new photos to existing ones instead of replacing
          final newImagePaths = pickedFiles.map((file) => file.path).toList();
          _images.addAll(newImagePaths);
          // Remove duplicates if any (based on file path)
          _images = _images.toSet().toList();
        });
        _updateFormData(); // Save to draft
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
          // Remove duplicates if any (based on file path)
          _images = _images.toSet().toList();
        });
        _updateFormData(); // Save to draft
      }
    } catch (e) {
      setState(() => _error = 'Failed to take photo: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    _updateFormData(); // Save to draft
  }

  // ---- Phase 4: Asset Creation ----
  Future<void> _submitItemAsDone() async {
    if (_saving) return;
    if (_currentUser == null) {
      setState(() => _error = 'No active user. Please log in.');
      return;
    }

    _updateFormData();

    if (!_validateCurrentStep() || _itemName.isEmpty || _description.isEmpty) {
      setState(() => _error = 'Please complete all required fields.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final assetData = {
        'ownerId': _currentUser!.id,
        'name': _itemName,
        'value': _price,
        'description': _description,
        'imagePaths': _images,
      };
      await ApiService.createAsset(assetData);
      
      await _clearDraft();

      if (!mounted) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item completed and posted successfully!'),
            backgroundColor: Color(0xFF87AE73),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _error = 'Failed to save item.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submitItem() async {
    if (_saving) return;
    if (_currentUser == null) {
      setState(() => _error = 'No active user. Please log in.');
      return;
    }

    _updateFormData();

    if (!_validateCurrentStep() || _itemName.isEmpty || _description.isEmpty) {
      setState(() => _error = 'Please complete all required fields.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final assetData = {
        'ownerId': _currentUser!.id,
        'name': _itemName,
        'value': _price,
        'description': _description,
        'imagePaths': _images,
      };
      await ApiService.createAsset(assetData);
      
      await _clearDraft();

      if (!mounted) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item created successfully!'),
            backgroundColor: Color(0xFF87AE73),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _error = 'Failed to save item.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---- Phase 5: Quit Confirmation ----
  Future<void> _showQuitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Item Creation'),
        content: const Text(
          'Are you sure you want to quit? You can save your progress as a draft.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // Just quit without saving
            },
            child: const Text('Quit'),
          ),
          ElevatedButton(
            onPressed: () async {
              _updateFormData();
              await _saveDraft();
              Navigator.pop(context, true); // Quit after saving draft
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Draft saved successfully!'),
                    backgroundColor: Color(0xFF87AE73),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF87AE73),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Draft & Quit'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context);
    }
  }

  // ---- Phase 6: UI Components ----
  Widget _buildProcessIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: GestureDetector(
              onTap: () => _goToStep(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    // Step Circle
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? const Color(0xFF87AE73)
                            : isActive
                            ? const Color(0xFF87AE73)
                            : Colors.grey[300],
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF87AE73)
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const FaIcon(
                                FontAwesomeIcons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Step Label
                    Text(
                      _stepTitles[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive
                            ? const Color(0xFF87AE73)
                            : isCompleted
                            ? Colors.grey[700]
                            : Colors.grey[500],
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildNameStep();
      case 1:
        return _buildDescriptionStep();
      case 2:
        return _buildPicturesStep();
      case 3:
        return _buildPriceStep();
      case 4:
        return _buildFinalizeStep();
      default:
        return _buildNameStep();
    }
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What would you like to call your item? *',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Item Name',
              hintText: 'e.g., Vintage Camera, Gaming Chair',
              border: OutlineInputBorder(),
              prefixIcon: SizedBox(
                width: 48,
                child: Center(child: FaIcon(FontAwesomeIcons.tag, size: 18)),
              ),
            ),
            onChanged: (value) => _updateFormData(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about your item *',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description *',
              hintText:
                  'Describe the condition, features, and any relevant details...',
              border: OutlineInputBorder(),
              prefixIcon: SizedBox(
                width: 48,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: FaIcon(FontAwesomeIcons.fileLines, size: 18),
                  ),
                ),
              ),
            ),
            onChanged: (value) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _maintenanceCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Maintenance Required',
              hintText:
                  'Any special care instructions or maintenance needed...',
              border: OutlineInputBorder(),
              prefixIcon: SizedBox(
                width: 48,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: FaIcon(FontAwesomeIcons.wrench, size: 18),
                  ),
                ),
              ),
            ),
            onChanged: (value) => _updateFormData(),
          ),
        ],
      ),
    );
  }

  Widget _buildPicturesStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Add photos of your item *',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'At least one photo is required. You can add more photos anytime.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Photo Grid Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _images.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.images,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No photos added yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        // Add Photos Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: const FaIcon(
                                FontAwesomeIcons.images,
                                size: 18,
                              ),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF87AE73),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _pickImageFromCamera,
                              icon: const FaIcon(
                                FontAwesomeIcons.camera,
                                size: 18,
                              ),
                              label: const Text('Camera'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF87AE73),
                                ),
                                foregroundColor: const Color(0xFF87AE73),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Add More Buttons (when photos exist)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickImages,
                                  icon: const FaIcon(
                                    FontAwesomeIcons.images,
                                    size: 16,
                                  ),
                                  label: const Text('Gallery'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF87AE73),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickImageFromCamera,
                                  icon: const FaIcon(
                                    FontAwesomeIcons.camera,
                                    size: 16,
                                  ),
                                  label: const Text('Camera'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF87AE73),
                                    ),
                                    foregroundColor: const Color(0xFF87AE73),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Photos Grid
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.0,
                                ),
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(File(_images[index])),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
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
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          if (_images.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${_images.length} photo${_images.length == 1 ? '' : 's'} added',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set your rental price (optional)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Price per day (HB)',
              hintText: '0.00 (optional)',
              border: OutlineInputBorder(),
              prefixIcon: SizedBox(
                width: 48,
                child: Center(
                  child: FaIcon(FontAwesomeIcons.dollarSign, size: 18),
                ),
              ),
              prefixText: 'HB ',
            ),
            onChanged: (value) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.circleInfo, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Consider similar items when pricing. You can always adjust later.',
                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalizeStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Review your item',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'This is how your item will appear to other users',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Center(child: _buildReviewCard()),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    const Color categoryColor = Color(0xFF87AE73);
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Optional: Add tap functionality to edit
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image header - using the same aspect ratio as category cards
              AspectRatio(
                aspectRatio: 16 / 12, // Same ratio as marketplace cards
                child: Container(
                  color: categoryColor.withOpacity(0.06),
                  child: _images.isNotEmpty
                      ? Image.file(
                          File(_images.first),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            return Center(
                              child: FaIcon(
                                FontAwesomeIcons.box,
                                size: 40,
                                color: categoryColor,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: FaIcon(
                            FontAwesomeIcons.box,
                            size: 40,
                            color: categoryColor,
                          ),
                        ),
                ),
              ),
              
              // Text content - using the same layout as marketplace cards
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _itemName.isNotEmpty ? _itemName : 'Item Name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _description.isNotEmpty ? _description : 'No description',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'HB ${_price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.camera,
                                size: 10,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${_images.length}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: categoryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Maintenance note (if any) - compact version
                    if (_maintenance.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            FaIcon(FontAwesomeIcons.wrench, size: 10, color: Colors.blue[700]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _maintenance,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Edit buttons - compact version
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _goToStep(0),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: categoryColor,
                              side: BorderSide(color: categoryColor),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('Edit', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _goToStep(2),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: categoryColor,
                              side: BorderSide(color: categoryColor),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('Photos', style: TextStyle(fontSize: 12)),
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
      ),
    );
  }

  Widget _buildReviewField(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(value, style: TextStyle(color: Colors.grey[700])),
            ),
            FaIcon(
              FontAwesomeIcons.penToSquare,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to avoid requiring a copyWith on your model
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
      // keep existing HB if present
      hippoBalanceCents: hippoBalanceCents ?? u.hippoBalanceCents,
    );
  }

  // ---- Phase 7: Main Build Method ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Item'),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark),
          onPressed: _showQuitDialog,
        ),
        actions: [
          if (_currentStep < _stepTitles.length - 1)
            TextButton(
              onPressed: _nextStep,
              child: const Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saving ? null : _submitItem,
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
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Process Indicator
          Container(color: Colors.white, child: _buildProcessIndicator()),

          // Error Display
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red[50],
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleExclamation,
                    color: Colors.red[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _error = null),
                    icon: FaIcon(
                      FontAwesomeIcons.xmark,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),

          // Step Content - Only scrollable for non-photo steps
          if (_currentStep == 2) // Photos step
            Expanded(child: _buildStepContent())
          else
            Expanded(child: SingleChildScrollView(child: _buildStepContent())),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primary action buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        _updateFormData();
                        await _saveDraft();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Draft saved!'),
                              backgroundColor: Color(0xFF87AE73),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      icon: const FaIcon(FontAwesomeIcons.floppyDisk),
                      label: const Text('Save Draft'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF87AE73)),
                        foregroundColor: const Color(0xFF87AE73),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _submitItemAsDone,
                      icon: _saving 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const FaIcon(FontAwesomeIcons.circleCheck),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF87AE73),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Back button row (only show if not on first step)
              if (_currentStep > 0) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
