import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ChecklistPhoto extends StatelessWidget {
  const ChecklistPhoto({
    super.key,
    required this.photoUrl,
    this.height = 200,
    this.borderRadius = 8,
  });

  final String photoUrl;
  final double height;
  final double borderRadius;

  bool get _isNetworkUrl =>
      photoUrl.startsWith('http://') || photoUrl.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (_isNetworkUrl) {
      return Image.network(
        photoUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _errorPlaceholder(),
      );
    }

    if (kIsWeb) {
      return _errorPlaceholder();
    }

    return Image.file(
      File(photoUrl),
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _errorPlaceholder(),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(child: Icon(Icons.broken_image)),
    );
  }
}
