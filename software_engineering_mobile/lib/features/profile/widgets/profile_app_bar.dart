import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../shared/widgets/app_settings_page.dart';
import '../../../shared/widgets/edit_profile_page.dart';
import '../../auth/login_screen.dart';

/// ProfileV2 App Bar component - handles the header section of the profile
/// Contains profile image, user info, background patterns, and navigation menu
class ProfileAppBar extends StatelessWidget {
  final String displayName;
  final String displayEmail;
  final File? profileImage;
  final VoidCallback onProfileImageTap;
  final bool isPickingImage;

  const ProfileAppBar({
    super.key,
    required this.displayName,
    required this.displayEmail,
    this.profileImage,
    required this.onProfileImageTap,
    this.isPickingImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF87AE73),
      actions: [
        PopupMenuButton<String>(
          icon: const FaIcon(
            FontAwesomeIcons.ellipsisVertical,
            color: Colors.white,
            size: 26,
          ),
          onSelected: (value) => _handleMenuSelection(context, value),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.penToSquare,
                    color: Color(0xFF87AE73),
                  ),
                  SizedBox(width: 8),
                  Text('Edit Profile'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.gear, color: Color(0xFF87AE73)),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.arrowRightFromBracket,
                    color: Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF87AE73), Color(0xFF6B8E5B)],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              _buildBackgroundPatterns(),
              // Profile content
              _buildProfileContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPatterns() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Profile picture with edit button
          _buildProfileImage(),
          const SizedBox(height: 16),
          // User name and email
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayEmail,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        GestureDetector(
          onTap: isPickingImage ? null : onProfileImageTap,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage: profileImage != null
                ? FileImage(profileImage!)
                : null,
            child: profileImage == null
                ? ProfilePicture(name: displayName, radius: 60, fontsize: 30)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isPickingImage ? null : onProfileImageTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF87AE73),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: isPickingImage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const FaIcon(
                      FontAwesomeIcons.camera,
                      color: Colors.white,
                      size: 16,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfilePage()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppSettingsPage()),
        );
        break;
      case 'logout':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        break;
    }
  }
}
