import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// EPIC BATTLE ANSWER TILE - Game-style answer option with glow and animations
class AnswerOptionTile extends StatefulWidget {
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

  @override
  State<AnswerOptionTile> createState() => _AnswerOptionTileState();
}

class _AnswerOptionTileState extends State<AnswerOptionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.isAnswered && widget.isCorrect) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnswerOptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnswered && widget.isCorrect && !oldWidget.isAnswered) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  List<Color> get _gradientColors {
    if (!widget.isAnswered) {
      return [AppColors.cosmicBlue, AppColors.cosmicPurple];
    }
    if (widget.isCorrect) {
      return AppColors.victoryGradient;
    }
    if (widget.isSelected && !widget.isCorrect) {
      return [AppColors.error, AppColors.errorDark];
    }
    return [Colors.grey.shade300, Colors.grey.shade400];
  }

  Color get _shadowColor {
    if (!widget.isAnswered) return AppColors.primary;
    if (widget.isCorrect) return AppColors.successGlow;
    if (widget.isSelected) return AppColors.error;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isAnswered
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isAnswered
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onTap();
            },
      onTapCancel:
          widget.isAnswered ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final glowIntensity =
                widget.isAnswered && widget.isCorrect ? 0.4 + (_glowController.value * 0.2) : 0.2;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  if (widget.isSelected || (widget.isAnswered && widget.isCorrect))
                    BoxShadow(
                      color: _shadowColor.withOpacity(glowIntensity),
                      blurRadius: 16 + (_glowController.value * 8),
                      spreadRadius: 2 + (_glowController.value * 2),
                    ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: widget.isSelected || (widget.isAnswered && (widget.isCorrect || widget.isSelected))
                      ? LinearGradient(
                          colors: _gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: widget.isSelected || (widget.isAnswered && (widget.isCorrect || widget.isSelected))
                      ? null
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.isAnswered
                        ? (widget.isCorrect
                            ? AppColors.successGlow
                            : (widget.isSelected
                                ? AppColors.error
                                : AppColors.grey200))
                        : (widget.isSelected
                            ? AppColors.primary
                            : AppColors.grey200),
                    width: widget.isSelected || (widget.isAnswered && (widget.isCorrect || widget.isSelected)) ? 3 : 2,
                  ),
                ),
                child: Row(
                  children: [
                    // Epic option badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: widget.isSelected || (widget.isAnswered && (widget.isCorrect || widget.isSelected))
                            ? LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.4),
                                  Colors.white.withOpacity(0.2),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  AppColors.primaryLight.withOpacity(0.2),
                                  AppColors.primary.withOpacity(0.2),
                                ],
                              ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.isSelected || (widget.isAnswered && (widget.isCorrect || widget.isSelected))
                              ? Colors.white.withOpacity(0.8)
                              : AppColors.primary.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: widget.isSelected || (widget.isAnswered && (widget.isCorrect || widget.isSelected))
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.text,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: widget.isSelected || (widget.isAnswered && (widget.isCorrect || widget.isSelected))
                              ? Colors.white
                              : AppColors.grey800,
                          fontWeight: widget.isSelected || (widget.isAnswered && (widget.isCorrect || widget.isSelected))
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Epic icon after answer
                    if (widget.isAnswered && (widget.isCorrect || widget.isSelected))
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
