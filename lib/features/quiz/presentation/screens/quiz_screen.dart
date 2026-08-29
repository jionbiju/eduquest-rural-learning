import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/answer_option_tile.dart';
import '../widgets/xp_reward_popup.dart';

/// Main quiz screen — shows one question at a time with adaptive difficulty.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.topicId});

  final String topicId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with SingleTickerProviderStateMixin {
  bool _showXpPopup = false;
  int _lastXpGain = 0;
  bool _initialized = false;

  static const _optionLabels = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    // Reset (and shuffle) the quiz each time this screen is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(quizProvider(widget.topicId).notifier).resetQuiz();
        setState(() => _initialized = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider(widget.topicId));
    final notifier = ref.read(quizProvider(widget.topicId).notifier);

    // Show loading until initialized and questions are loaded.
    if (!_initialized || quizState.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Navigate to results when quiz is complete (but NOT on an empty/reset state).
    if (quizState.isCompleted && quizState.questions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.goNamed(
            'quiz_result',
            pathParameters: {'lessonId': widget.topicId},
            extra: {
              'correctCount': quizState.correctCount,
              'totalQuestions': quizState.totalQuestions,
              'xpEarned': quizState.xpEarned,
              'topicId': widget.topicId,
            },
          );
        }
      });
    }

    final question = quizState.currentQuestion;
    final progress =
        (quizState.currentIndex + 1) / quizState.totalQuestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Question ${quizState.currentIndex + 1} of ${quizState.totalQuestions}',
          style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              backgroundColor: AppColors.primaryDark,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.secondaryLight),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Main quiz content ────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Difficulty indicator ─────────────────────────────
                Row(
                  children: [
                    _DifficultyDots(difficulty: question.difficulty),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '⭐ ${_xpForDifficulty(question.difficulty)} XP',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Question text ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.grey200),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    question.localizedText('en'),
                    style: AppTextStyles.headlineMedium,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Answer options ───────────────────────────────────
                ...List.generate(question.options.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnswerOptionTile(
                      index: i,
                      label: _optionLabels[i],
                      text: question.options[i],
                      isSelected: quizState.selectedAnswer == i,
                      isCorrect: i == question.correctIndex,
                      isAnswered: quizState.isAnswered,
                      onTap: () {
                        notifier.selectAnswer(i);
                        if (i == question.correctIndex) {
                          setState(() {
                            _showXpPopup = true;
                            _lastXpGain =
                                _xpForDifficulty(question.difficulty);
                          });
                          Future.delayed(
                            const Duration(milliseconds: 1300),
                            () {
                              if (mounted) {
                                setState(() => _showXpPopup = false);
                              }
                            },
                          );
                        }
                      },
                    ),
                  );
                }),

                // ── Explanation (shown after answer) ─────────────────
                if (quizState.isAnswered) ...[
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: quizState.isCorrect
                          ? AppColors.success.withValues(alpha: 0.08)
                          : AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: quizState.isCorrect
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quizState.isCorrect ? '✅' : '❌',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quizState.isCorrect
                                    ? 'Correct!'
                                    : 'Not quite!',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: quizState.isCorrect
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                question.localizedExplanation('en'),
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: quizState.isLastQuestion
                        ? 'See Results'
                        : 'Next Question',
                    icon: quizState.isLastQuestion
                        ? Icons.emoji_events_rounded
                        : Icons.arrow_forward_rounded,
                    onPressed: notifier.nextQuestion,
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),

          // ── XP Reward floating popup ─────────────────────────────────
          if (_showXpPopup)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: XpRewardPopup(xp: _lastXpGain),
              ),
            ),
        ],
      ),
    );
  }

  int _xpForDifficulty(int difficulty) {
    switch (difficulty) {
      case 1:
        return 10;
      case 2:
        return 15;
      case 3:
        return 20;
      default:
        return 10;
    }
  }
}

/// Three dots showing difficulty level.
class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots({required this.difficulty});
  final int difficulty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final active = i < difficulty;
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.secondary : AppColors.grey200,
          ),
        );
      }),
    );
  }
}
