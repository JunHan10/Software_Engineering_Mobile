// Importing necessary packages
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Entry point of the application
void main() {
  runApp(const MaterialApp(home: ProfilePage()));
}


/// Profile page where user can tap to pick and persist a profile picture
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Variable to store the selected image file
  File? _pickedImage;

  // Lock flag to prevent opening picker multiple times at once
  bool _isPickingImage = false;
  
  // Animation state for back button
  bool _isBackPressed = false;
  Timer? _backPressedTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedImage(); // Load saved profile picture from local storage on startup
  }

  /// Loads the saved image path from SharedPreferences
  /// and checks if the file still exists before displaying
  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_image_path');

    // Check if the path exists and is valid
    if (savedPath != null && File(savedPath).existsSync()) {
      setState(() {
        _pickedImage = File(savedPath);
      });
    }
  }

  /// Picks an image from the gallery and saves the path
  /// to SharedPreferences for persistence
  Future<void> _pickImage() async {
    if (_isPickingImage) return; // Prevent multiple calls

    _isPickingImage = true;

  try {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final path = pickedFile.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', path);

      setState(() {
        _pickedImage = File(path);
      });
    }
  } catch (_) {
    // Silently catch errors — no print, no log
  } finally {
    _isPickingImage = false;
  }
}

final List<File> _imageFiles = [];

Future<void> _pickMultipleImages() async {
  final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();
  if (pickedFiles.isNotEmpty) {
    setState(() {
      _imageFiles.addAll(pickedFiles.map((xfile) => File(xfile.path)));
    });
  }
}

void _removeImage(int index) {
  setState(() {
    _imageFiles.removeAt(index);
  });
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 231, 228, 213),
      body: Stack(
        children: [
          Column(
        children: [
          //  Top Section: Black background with profile picture
          Container(
            width: double.infinity,
            height: 300,
            color: Color(0xFF87AE73),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: _pickImage, // Tap to pick image
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white,
                backgroundImage:
                    _pickedImage != null ? FileImage(_pickedImage!) : null,
                child: _pickedImage == null
                    ? ProfilePicture(
                        name: 'John King',
                        radius: 80,
                        fontsize: 40,
                      )
                    : null,
              ),
            ),
          ),

          // ⚫ Divider line under black section
          const Divider(
            height: 0,
            thickness: 1,
            color: Colors.white,
          ),

          // 🔽 Bottom Section: Expandable content area
          Expanded(
            child: Container(
              width: double.infinity,
              color: Color.fromARGB(255, 231, 228, 213),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickMultipleImages,
                        icon: Icon(Icons.add_photo_alternate),
      label: Text('Add Images'),
    ),
    const SizedBox(height: 10),
    
    // Display images
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_imageFiles.length, (index) {
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_imageFiles[index]),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    ),
  ],
),
        ],),
            ),
          ),
            ],
          ),
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 231, 228, 213),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _isBackPressed = true);
                    Timer(Duration(milliseconds: 200), () {
                      if (mounted) {
                        setState(() => _isBackPressed = false);
                        Navigator.pop(context);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color.fromARGB(255, 231, 228, 213).withValues(alpha: 0.9),
                      boxShadow: _isBackPressed
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                offset: Offset(0, 4),
                                blurRadius: 8,
                                inset: true,
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.8),
                                offset: Offset(0, -2),
                                blurRadius: 4,
                                inset: true,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                inset: true,
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.6),
                                offset: Offset(0, -1),
                                blurRadius: 2,
                                inset: true,
                              ),
                            ],
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.bounceOut,
                      transform: Matrix4.translationValues(0, _isBackPressed ? 6.0 : 2.0, 0),
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFF87AE73),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}