import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class ProfileImageWidget extends StatelessWidget {
  final File? pickedImage;
  final String displayName;
  final VoidCallback onTap;

  const ProfileImageWidget({
    super.key,
    required this.pickedImage,
    required this.displayName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 80,
        backgroundColor: Colors.white,
        backgroundImage: pickedImage != null ? FileImage(pickedImage!) : null,
        child: pickedImage == null
            ? ProfilePicture(
                name: displayName,
                radius: 80,
                fontsize: 40,
              )
            : null,
      ),
    );
  }
}
