import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Single badge display — emoji icon + label.
class BadgeChip extends StatelessWidget {
  const BadgeChip({
    super.key,
    required this.emoji,
    required this.label,
    this.earned = true,
  });

  final String emoji;
  final String label;

  /// Unearned badges render greyed out.
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1.0 : 0.35,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: earned
                  ? AppColors.badgePurple.withValues(alpha: 0.12)
                  : AppColors.grey100,
              shape: BoxShape.circle,
              border: Border.all(
                color: earned ? AppColors.badgePurple : AppColors.grey200,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
