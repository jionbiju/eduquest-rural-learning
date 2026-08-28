import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../home/providers/home_provider.dart';

/// Summary screen shown after a quiz is completed.
class QuizResultScreen extends ConsumerStatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.correctCount,
    required this.totalQuestions,
    required this.xpEarned,
    required this.topicId,
  });

  final int correctCount;
  final int totalQuestions;
  final int xpEarned;
  final String topicId;

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  @override
  void initState() {
    super.initState();
    // Award XP to student profile after quiz completes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.xpEarned > 0) {
        ref.read(studentProfileProvider.notifier).addXp(widget.xpEarned);
      }
      // First lesson badge.
      ref
          .read(studentProfileProvider.notifier)
          .earnBadge('first_lesson');
    });
  }

  double get _accuracy => widget.totalQuestions > 0
      ? widget.correctCount / widget.totalQuestions
      : 0;

  String get _resultEmoji {
    if (_accuracy >= 0.8) return '🏆';
    if (_accuracy >= 0.5) return '👍';
    return '💪';
  }

  String get _resultTitle {
    if (_accuracy >= 0.8) return 'Excellent!';
    if (_accuracy >= 0.5) return 'Good job!';
    return 'Keep going!';
  }

  String get _resultMessage {
    if (_accuracy >= 0.8) return 'You crushed it! Your score is amazing.';
    if (_accuracy >= 0.5) return 'Solid effort! Review the ones you missed.';
    return 'Practice makes perfect. Try again to improve!';
  }

  Color get _scoreColor {
    if (_accuracy >= 0.8) return AppColors.success;
    if (_accuracy >= 0.5) return AppColors.secondary;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(_resultEmoji, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text(_resultTitle, style: AppTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text(
                _resultMessage,
                style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.grey600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Score',
                          value:
                              '${widget.correctCount} / ${widget.totalQuestions}',
                          color: _scoreColor,
                        ),
                        Container(width: 1, height: 48, color: AppColors.grey200),
                        _StatItem(
                          label: 'Accuracy',
                          value: '${(_accuracy * 100).toInt()}%',
                          color: _scoreColor,
                        ),
                        Container(width: 1, height: 48, color: AppColors.grey200),
                        _StatItem(
                          label: 'XP Earned',
                          value: '+${widget.xpEarned}',
                          color: AppColors.xpGold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _accuracy),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOut,
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v,
                          minHeight: 12,
                          backgroundColor: AppColors.grey100,
                          valueColor: AlwaysStoppedAnimation(_scoreColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Back to Home',
                icon: Icons.home_rounded,
                onPressed: () => context.goNamed('home'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.goNamed(
                    'quiz',
                    pathParameters: {'lessonId': widget.topicId},
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => context.goNamed('leaderboard'),
                icon: const Icon(Icons.leaderboard_rounded),
                label: const Text('View Leaderboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displayMedium.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
