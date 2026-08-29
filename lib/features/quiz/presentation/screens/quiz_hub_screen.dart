import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../lessons/data/models/topic_model.dart';
import '../../../lessons/data/repositories/bundle_repository.dart';

/// Quiz hub screen — lets the user pick a topic to start a fresh quiz.
class QuizHubScreen extends ConsumerWidget {
  const QuizHubScreen({super.key});

  static const _topicColors = [
    AppColors.primary,
    AppColors.success,
    AppColors.secondary,
    AppColors.badgePurple,
    AppColors.xpGold,
    AppColors.primary,
  ];

  Color _colorForIndex(int i) => _topicColors[i % _topicColors.length];

  String _emojiForTopic(TopicModel topic) {
    if (topic.id.startsWith('math_addition')) return '➕';
    if (topic.id.startsWith('math_sub')) return '➖';
    if (topic.id.startsWith('math_mul')) return '✖️';
    if (topic.id.startsWith('math')) return '🔢';
    if (topic.id.startsWith('science_plants')) return '🌱';
    if (topic.id.startsWith('science_water')) return '💧';
    if (topic.id.startsWith('science_animals')) return '🐾';
    return '📝';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Quiz',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6D28D9), AppColors.secondary],
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 48, right: 20),
                    child: Text('🧠', style: TextStyle(fontSize: 52)),
                  ),
                ),
              ),
            ),
          ),

          // ── Subtitle ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Pick a topic to test yourself. Each attempt generates a different quiz!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          subjectsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Could not load topics: $e',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
            data: (subjects) {
              // Flatten all topics across all subjects with a color index.
              final allTopics = <(TopicModel, String, int)>[];
              var colorIndex = 0;
              for (final subject in subjects) {
                for (final topic in subject.topics) {
                  allTopics.add((topic, subject.localizedName('en'), colorIndex));
                  colorIndex++;
                }
              }

              if (allTopics.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No topics available.')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final (topic, subjectName, ci) = allTopics[i];
                      final color = _colorForIndex(ci);
                      return _QuizTopicCard(
                        topic: topic,
                        subjectName: subjectName,
                        color: color,
                        emoji: _emojiForTopic(topic),
                      );
                    },
                    childCount: allTopics.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Quiz topic card ───────────────────────────────────────────────────────────

class _QuizTopicCard extends StatelessWidget {
  const _QuizTopicCard({
    required this.topic,
    required this.subjectName,
    required this.color,
    required this.emoji,
  });

  final TopicModel topic;
  final String subjectName;
  final Color color;
  final String emoji;

  String _difficultyLabel(int d) {
    if (d == 1) return 'Easy';
    if (d == 2) return 'Medium';
    return 'Hard';
  }

  Color _difficultyColor(int d) {
    if (d == 1) return AppColors.success;
    if (d == 2) return AppColors.secondary;
    return AppColors.error;
  }

  int _maxXp(TopicModel t) {
    return t.questions.fold(0, (sum, q) {
      if (q.difficulty == 1) return sum + 10;
      if (q.difficulty == 2) return sum + 15;
      return sum + 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dColor = _difficultyColor(topic.difficulty);
    return GestureDetector(
      onTap: () => context.goNamed(
        'quiz',
        pathParameters: {'lessonId': topic.id},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Emoji circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),

              // Topic info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.localizedName('en'),
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subjectName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Difficulty badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: dColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _difficultyLabel(topic.difficulty),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: dColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${topic.questions.length} Qs',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '⭐ up to ${_maxXp(topic)} XP',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.xpGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Start arrow button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
