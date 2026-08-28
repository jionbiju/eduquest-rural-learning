import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../providers/lesson_provider.dart';
import '../widgets/audio_player_bar.dart';
import '../widgets/difficulty_badge.dart';
import '../widgets/lesson_illustration.dart';

/// Displays a single topic lesson with text, illustration, and audio.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.topicId});

  final String topicId;

  /// Maps topicId prefix to an emoji for illustrations.
  String _emojiForTopic(String id) {
    if (id.startsWith('math')) return '🔢';
    if (id.startsWith('science_plants')) return '🌱';
    if (id.startsWith('science_water')) return '💧';
    if (id.startsWith('science_animals')) return '🐾';
    return '📚';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicAsync = ref.watch(topicByIdProvider(topicId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: topicAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text('Could not load lesson: $e'),
        ),
        data: (topic) {
          if (topic == null) {
            return Center(
              child: Text(
                'Lesson not found',
                style: AppTextStyles.headlineMedium,
              ),
            );
          }

          // Use English for now — locale switching comes with settings screen.
          const locale = 'en';

          return CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  topic.localizedName(locale),
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: DifficultyBadge(difficulty: topic.difficulty),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Illustration ──────────────────────────────────
                      LessonIllustration(
                        illustrationRef: topic.illustrationRef,
                        subjectEmoji: _emojiForTopic(topic.id),
                      ),
                      const SizedBox(height: 20),

                      // ── Audio narration bar ───────────────────────────
                      AudioPlayerBar(
                        audioRef: topic.audioRef,
                        language: locale,
                      ),
                      const SizedBox(height: 24),

                      // ── Lesson content ────────────────────────────────
                      Row(
                        children: [
                          const Text('📝', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            'Lesson',
                            style: AppTextStyles.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.grey200,
                          ),
                        ),
                        child: Text(
                          topic.localizedLessonText(locale),
                          style: AppTextStyles.bodyLarge.copyWith(
                            height: 1.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Question count info ───────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.quiz_outlined,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${topic.questions.length} questions ready — '
                                'earn up to ${topic.questions.length * AppConstants.xpPerCorrectAnswer + AppConstants.xpPerLessonComplete} XP',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Start Quiz CTA ────────────────────────────────
                      PrimaryButton(
                        label: 'Start Quiz',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => context.goNamed(
                          'quiz',
                          pathParameters: {'lessonId': topicId},
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Back to Subjects'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
