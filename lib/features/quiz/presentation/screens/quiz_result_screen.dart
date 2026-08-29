import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../home/providers/daily_quest_provider.dart';
import '../../../home/providers/home_provider.dart';
import '../../../sync/data/models/sync_action.dart';
import '../../../sync/providers/sync_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profile = ref.read(studentProfileProvider);
      final syncService = ref.read(syncServiceProvider);
      final notifier = ref.read(studentProfileProvider.notifier);

      // 1. Award XP locally.
      if (widget.xpEarned > 0) {
        notifier.addXp(widget.xpEarned);

        // Queue XP sync action.
        await syncService.enqueue(
          SyncAction(
            id: const Uuid().v4(),
            type: SyncActionType.xpEarned,
            studentId: profile.id,
            payload: {'amount': widget.xpEarned},
            createdAt: DateTime.now(),
          ),
        );
      }

      // 2. Queue lesson completed sync action.
      await syncService.enqueue(
        SyncAction.lessonCompleted(
          id: const Uuid().v4(),
          studentId: profile.id,
          lessonId: widget.topicId,
          xpEarned: widget.xpEarned,
        ),
      );

      // 3. Award first lesson badge locally + queue.
      notifier.earnBadge('first_lesson');
      await syncService.enqueue(
        SyncAction(
          id: const Uuid().v4(),
          type: SyncActionType.badgeEarned,
          studentId: profile.id,
          payload: {'badgeId': 'first_lesson'},
          createdAt: DateTime.now(),
        ),
      );

      // 4. Record daily quest progress.
      await ref.read(dailyQuestProvider.notifier).recordQuizCompletion();

      // 5. Try to increment streak (only once per day).
      final streakIncremented =
          await ref.read(streakTrackerProvider.notifier).tryIncrementStreak();
      if (streakIncremented) {
        notifier.incrementStreak();
        await syncService.enqueue(
          SyncAction(
            id: const Uuid().v4(),
            type: SyncActionType.streakUpdated,
            studentId: profile.id,
            payload: {'streak': ref.read(studentProfileProvider).streak},
            createdAt: DateTime.now(),
          ),
        );
      }

      // 6. Flush queue immediately (online sync if connected).
      await syncService.flushQueue();
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
                  // Use go() with full path to avoid GoRouter nested param issues.
                  // Path: /home/lesson/{topicId}/quiz
                  onPressed: () => context.go(
                    '/home/lesson/${widget.topicId}/quiz',
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
