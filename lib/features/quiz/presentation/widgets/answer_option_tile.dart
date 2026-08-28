import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A single answer option tile for the quiz screen.
/// Shows correct/incorrect state after the student answers.
class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    super.key,
    required this.index,
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswered,
    required this.onTap,
  });

  final int index;
  final String label;   // A, B, C, D
  final String text;
  final bool isSelected;
  final bool isCorrect; // whether THIS option is the correct answer
  final bool isAnswered; // whether ANY answer has been submitted
  final VoidCallback onTap;

  Color get _borderColor {
    if (!isAnswered) return AppColors.grey200;
    if (isCorrect) return AppColors.success;
    if (isSelected && !isCorrect) return AppColors.error;
    return AppColors.grey200;
  }

  Color get _bgColor {
    if (!isAnswered) return Colors.white;
    if (isCorrect) return AppColors.success.withValues(alpha: 0.08);
    if (isSelected && !isCorrect) return AppColors.error.withValues(alpha: 0.08);
    return Colors.white;
  }

  Color get _labelBg {
    if (!isAnswered) return AppColors.surfaceVariant;
    if (isCorrect) return AppColors.success;
    if (isSelected && !isCorrect) return AppColors.error;
    return AppColors.surfaceVariant;
  }

  Color get _labelColor {
    if (!isAnswered) return AppColors.primary;
    if (isCorrect || (isSelected && !isCorrect)) return Colors.white;
    return AppColors.grey600;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAnswered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor, width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _borderColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Option label circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _labelBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: _labelColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyLarge,
              ),
            ),
            // Tick / cross icon after answer
            if (isAnswered && (isCorrect || isSelected))
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: isCorrect ? AppColors.success : AppColors.error,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
