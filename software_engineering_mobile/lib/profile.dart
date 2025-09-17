// Importing necessary packages
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'settings_page.dart';
import 'services/auth_service.dart';

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
    final currentUser = AuthService.currentUser;
    final fullName = currentUser != null 
        ? '${currentUser.firstName} ${currentUser.lastName}'
        : 'John King';
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 228, 213),
      body: Stack(
        children: [
          Column(
            children: [
              // Top Section: Green background with profile picture
              Container(
                width: double.infinity,
                height: 300,
                color: const Color(0xFF87AE73),
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
                            name: fullName,
                            radius: 80,
                            fontsize: 40,
                          )
                        : null,
                  ),
                ),
              ),

              // Divider line under green section
              const Divider(
                height: 0,
                thickness: 1,
                color: Colors.white,
              ),

              // Bottom Section: User information and images
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 231, 228, 213),
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Information Section
                        if (currentUser != null) ...[
                          _buildInfoCard(
                            'Personal Information',
                            [
                              _buildInfoRow('Name', fullName),
                              if (currentUser.phone != null)
                                _buildInfoRow('Phone', currentUser.phone!),
                              _buildInfoRow('Email', currentUser.email),
                              if (currentUser.age != null)
                                _buildInfoRow('Age', currentUser.age.toString()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Address Information
                          if (currentUser.streetAddress != null || 
                              currentUser.city != null || 
                              currentUser.state != null || 
                              currentUser.zipcode != null)
                            _buildInfoCard(
                              'Address',
                              [
                                if (currentUser.streetAddress != null)
                                  _buildInfoRow('Street', currentUser.streetAddress!),
                                if (currentUser.city != null)
                                  _buildInfoRow('City', currentUser.city!),
                                if (currentUser.state != null)
                                  _buildInfoRow('State', currentUser.state!),
                                if (currentUser.zipcode != null)
                                  _buildInfoRow('ZIP Code', currentUser.zipcode!),
                              ],
                            ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Images Section
                        _buildInfoCard(
                          'Images',
                          [
                            ElevatedButton.icon(
                              onPressed: _pickMultipleImages,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text('Add Images'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF87AE73),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // Display images
                            if (_imageFiles.isNotEmpty)
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
                                              decoration: const BoxDecoration(
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
                              )
                            else
                              const Text(
                                'No images added yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          
          // Settings button
          Positioned(
            top: 50,
            right: 60,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ).then((_) {
                  // Refresh the page when returning from settings
                  setState(() {});
                });
              },
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          
          // Logout button
          Positioned(
            top: 50,
            right: 16,
            child: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF87AE73),
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}