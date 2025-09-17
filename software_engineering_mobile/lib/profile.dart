// Importing necessary packages
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// NEW: App models / repositories / money utilities for Hippo Bucks
import 'models/user.dart';
import 'repositories/shared_prefs_user_repository.dart';
import 'services/money_service.dart';
import 'dashboard_page.dart'; // 👈 Import so we can navigate back
import 'login_screen.dart';
import 'settings_page.dart';
import 'services/auth_service.dart';

/// Entry point of the application
/// NOTE: Your app usually starts from lib/main.dart.
/// Keeping this here is harmless; Flutter will still use main.dart as entry.
void main() {
  runApp(const MaterialApp(home: ProfilePage()));
}

/// Profile page where user can tap to pick and persist a profile picture
/// + (NEW) manage Hippo Bucks (HB) balance
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

  // ---------------------------------------------------------------------------
  // NEW: Hippo Bucks fields
  // ---------------------------------------------------------------------------
  final _repo = SharedPrefsUserRepository(); // concrete local repo
  User? _user;                   // active user for this page
  int _hippoBalanceCents = 0;    // HB stored in cents
  bool _loadingUser = true;      // gate UI until we try to load

  // Gallery state (your existing)
  final List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSavedImage();         // Load saved profile picture from local storage
    _initUserAndBalance();     // NEW: Load active user + HB balance
  }

  // ---------------------------------------------------------------------------
  // Load active user & HB balance
  // ---------------------------------------------------------------------------
  Future<void> _initUserAndBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('activeUserId') ?? 'active_user';
    final bal = await _repo.getHippoBalanceCents(userId);

    setState(() {
      _user = User(
        id: userId,
        email: '', password: '',
        firstName: 'Profile', lastName: '',
        currency: 0.0, assets: const [],
        hippoBalanceCents: bal,
      );
      _hippoBalanceCents = bal;
      _loadingUser = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Hippo Bucks actions
  // ---------------------------------------------------------------------------
  Future<void> _promptAndDeposit() async {
    if (_user?.id == null) return _showNeedUserSnack();
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
    if (_user?.id == null) return _showNeedUserSnack();
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

  void _showNeedUserSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No user available. Log in first.')),
    );
    return;
  }

  // ---------------------------------------------------------------------------
  // Existing image helpers (unchanged)
  // ---------------------------------------------------------------------------
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
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
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
    } catch (_) {
      // Silently catch errors
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
    setState(() {
      _imageFiles.removeAt(index);
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(
        backgroundColor: Colors.teal,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          },
        ),
      ),
      backgroundColor: Colors.teal,
      body: Column(
        children: [
          // 🔳 Top Section: Black background with profile picture
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.black,
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

          // 🔽 Bottom Section
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.teal,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickMultipleImages,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add Images'),
                        ),
                        const SizedBox(height: 10),

                        // Display gallery
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

                        // HB Wallet
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: _promptAndWithdraw,
                                      icon: const Icon(Icons.remove),
                                      label: const Text('Spend'),
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
                ],
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
