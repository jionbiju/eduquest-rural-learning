import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Small pill showing lesson difficulty level.
class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({super.key, required this.difficulty});

  final int difficulty; // 1, 2, or 3

  String get _label {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Easy';
    }
  }

  Color get _color {
    switch (difficulty) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.secondary;
      case 3:
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color, width: 1.5),
      ),
      child: Text(
        _label,
        style: AppTextStyles.labelSmall.copyWith(color: _color),
      ),
    );
  }
}
