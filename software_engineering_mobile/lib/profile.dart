import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(home: ProfilePage()));
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_image_path');
    if (savedPath != null && File(savedPath).existsSync()) {
      setState(() {
        _pickedImage = File(savedPath);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final path = pickedFile.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', path);

      setState(() {
        _pickedImage = File(path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: GestureDetector(
          onTap: _pickImage,
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
    );
  }
}
