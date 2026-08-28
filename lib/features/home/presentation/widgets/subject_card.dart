import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Card displayed in the home subject grid.
/// Tapping navigates to the lesson list for that subject.
class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.color,
    required this.topicsCount,
    required this.onTap,
  });

  final String title;
  final String emoji;
  final Color color;
  final int topicsCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject emoji icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.grey800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$topicsCount topics',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
