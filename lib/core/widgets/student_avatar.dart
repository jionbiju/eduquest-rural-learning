import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Circular avatar for the student.
/// Shows a network/asset image if [imageUrl] is provided,
/// otherwise falls back to initials.
class StudentAvatar extends StatelessWidget {
  const StudentAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 32,
    this.showBorder = true,
  });

  final String name;
  final String? imageUrl;
  final double radius;
  final bool showBorder;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: AppColors.primary, width: 2.5)
            : null,
        color: AppColors.surfaceVariant,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _InitialsFallback(
                  initials: _initials,
                  radius: radius,
                ),
              )
            : _InitialsFallback(initials: _initials, radius: radius),
      ),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.initials, required this.radius});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontSize: radius * 0.6,
          ),
        ),
      ),
    );
  }
}
