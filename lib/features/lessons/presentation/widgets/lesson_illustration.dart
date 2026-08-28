import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Displays the lesson illustration.
/// Falls back to an emoji placeholder if the asset isn't available yet.
class LessonIllustration extends StatelessWidget {
  const LessonIllustration({
    super.key,
    required this.illustrationRef,
    required this.subjectEmoji,
  });

  final String illustrationRef;
  final String subjectEmoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceVariant, Color(0xFFDDD6FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Emoji placeholder — replace with Image.asset when art is ready
          Center(
            child: Text(
              subjectEmoji,
              style: const TextStyle(fontSize: 80),
            ),
          ),
        ],
      ),
    );
  }
}
