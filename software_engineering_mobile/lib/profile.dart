// lib/profile.dart
//
// Profile + wallet (Hippo Bucks) + image gallery. UI preserved with wallet added.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user.dart';
import 'repositories/shared_prefs_user_repository.dart';
import 'services/money_service.dart';
import 'settings_page.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  bool _isPickingImage = false;

  // HB state
  final _repo = SharedPrefsUserRepository();
  User? _user;
  int _hippoBalanceCents = 0;
  bool _loadingUser = true;

  // Gallery
  final List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
    _initUserAndBalance();
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_image_path');
    if (savedPath != null && File(savedPath).existsSync()) {
      setState(() => _pickedImage = File(savedPath));
    }
  }

  Future<void> _initUserAndBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('activeUserId'); // set at login
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _user = null;
        _hippoBalanceCents = 0;
        _loadingUser = false;
      });
      return;
    }
    final bal = await _repo.getHippoBalanceCents(userId);
    if (!mounted) return;
    setState(() {
      _user = User(
        id: userId,
        email: '',
        password: '',
        firstName: 'Profile',
        lastName: '',
        currency: 0.0,
        assets: const [],
        hippoBalanceCents: bal,
      );
      _hippoBalanceCents = bal;
      _loadingUser = false;
    });
  }

  // --- HB actions ---

  Future<void> _promptAndDeposit() async {
    if (_user?.id == null) return _needUserSnack();
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Hippo Bucks'),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: 'HB '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok == true) {
      final cents = MoneyService.parseToCents(c.text);
      await _repo.depositHippoCents(_user!.id!, cents);
      final bal = await _repo.getHippoBalanceCents(_user!.id!);
      if (!mounted) return;
      setState(() => _hippoBalanceCents = bal);
    }
  }

  Future<void> _promptAndWithdraw() async {
    if (_user?.id == null) return _needUserSnack();
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Spend Hippo Bucks'),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: 'HB '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Spend')),
        ],
      ),
    );
    if (ok == true) {
      final cents = MoneyService.parseToCents(c.text);
      await _repo.withdrawHippoCents(_user!.id!, cents);
      final bal = await _repo.getHippoBalanceCents(_user!.id!);
      if (!mounted) return;
      setState(() => _hippoBalanceCents = bal);
    }
  }

  void _needUserSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No user available. Please log in first.')),
    );
  }

  // --- Image helpers ---

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final path = pickedFile.path;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', path);
        setState(() => _pickedImage = File(path));
      }
    } catch (_) {
      // ignore
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _pickMultipleImages() async {
    final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(pickedFiles.map((xfile) => File(xfile.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _imageFiles.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(
        backgroundColor: Color(0xFF87AE73),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 228, 213),
      body: Stack(
        children: [
          Column(
            children: [
              // Top section with profile picture
              Container(
                width: double.infinity,
                height: 300,
                color: const Color(0xFF87AE73),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white,
                    backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
                    child: _pickedImage == null
                        ? ProfilePicture(
                            name: _user?.firstName ?? 'User',
                            radius: 80,
                            fontsize: 40,
                          )
                        : null,
                  ),
                ),
              ),

              const Divider(height: 0, thickness: 1, color: Colors.white),

              // Bottom section
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 231, 228, 213),
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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

                              // Gallery
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
                                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Wallet card
                              Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                color: Colors.white,
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hippo Bucks',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        MoneyService.formatCents(_hippoBalanceCents),
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.black87),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 10,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: _promptAndDeposit,
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF87AE73),
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: _promptAndWithdraw,
                                            icon: const Icon(Icons.remove),
                                            label: const Text('Spend'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFF87AE73),
                                              side: const BorderSide(color: Color(0xFF87AE73)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
}
