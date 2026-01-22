import 'dart:io';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const ProfileAvatar({super.key, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
        child: imagePath == null
            ? Icon(
                Icons.camera_alt,
                size: 40,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : null,
      ),
    );
  }
}
