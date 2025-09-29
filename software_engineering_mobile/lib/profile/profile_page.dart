import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../repositories/shared_prefs_user_repository.dart';
import '../services/money_service.dart';
import '../setting/settings_ui.dart' as settings;
import '../login_screen.dart';

import 'profile_avatar.dart';
import 'profile_background.dart';
import 'profile_wallet.dart';
import 'profile_gallery.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  bool _isPickingImage = false;

  final _repo = SharedPrefsUserRepository();
  User? _user;
  int _hippoBalanceCents = 0;
  bool _loadingUser = true;

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
    final userId = prefs.getString('activeUserId');
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
              Container(
                width: double.infinity,
                height: 300,
                color: const Color(0xFF87AE73),
                alignment: Alignment.center,
                child: ProfileImageWidget(
                  pickedImage: _pickedImage,
                  displayName: _user?.firstName ?? 'User',
                  onTap: _pickImage,
                ),
              ),

              const Divider(height: 0, thickness: 1, color: Colors.white),

              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 231, 228, 213),
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.all(16),
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
                        ProfileGallery(
                          imageFiles: _imageFiles,
                          onAddImages: _pickMultipleImages,
                          onRemoveImage: _removeImage,
                        ),

                        const SizedBox(height: 16),

                        ProfileWallet(
                          balanceCents: _hippoBalanceCents,
                          onDeposit: _promptAndDeposit,
                          onWithdraw: _promptAndWithdraw,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

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

          Positioned(
            top: 50,
            right: 60,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const settings.SettingsPage()),
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


