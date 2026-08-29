import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../lessons/data/models/subject_model.dart';
import '../../../lessons/data/models/topic_model.dart';
import '../../../lessons/data/repositories/bundle_repository.dart';

/// Shows all topics under one subject and lets the user pick one.
class SubjectTopicsScreen extends ConsumerWidget {
  const SubjectTopicsScreen({super.key, required this.subjectId});

  final String subjectId;

  static const _colors = [
    AppColors.primary,
    AppColors.success,
    AppColors.secondary,
    AppColors.badgePurple,
    AppColors.xpGold,
  ];

  Color _colorForIndex(int i) => _colors[i % _colors.length];

  String _emojiForSubject(SubjectModel s) {
    if (s.id.startsWith('math')) return '🔢';
    if (s.id.startsWith('science')) return '🔬';
    return '📚';
  }

  String _emojiForTopic(TopicModel t) {
    if (t.id.startsWith('math_addition')) return '➕';
    if (t.id.startsWith('math_sub')) return '➖';
    if (t.id.startsWith('math_mul')) return '✖️';
    if (t.id.startsWith('math')) return '🔢';
    if (t.id.startsWith('science_plants')) return '🌱';
    if (t.id.startsWith('science_water')) return '💧';
    if (t.id.startsWith('science_animals')) return '🐾';
    return '📄';
  }

  Color _difficultyColor(int d) {
    if (d == 1) return AppColors.success;
    if (d == 2) return AppColors.secondary;
    return AppColors.error;
  }

  String _difficultyLabel(int d) {
    if (d == 1) return 'Easy';
    if (d == 2) return 'Medium';
    return 'Hard';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return subjectsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (subjects) {
        SubjectModel? subject;
        try {
          subject = subjects.firstWhere((s) => s.id == subjectId);
        } catch (_) {
          subject = null;
        }

        if (subject == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not found')),
            body: const Center(child: Text('Subject not found')),
          );
        }

        final subjectEmoji = _emojiForSubject(subject);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 130,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    subject.localizedName('en'),
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryDark, AppColors.primary],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 48, right: 20),
                        child: Text(
                          subjectEmoji,
                          style: const TextStyle(fontSize: 52),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Subtitle ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    '${subject.topics.length} topics available — tap one to start learning',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ),
              ),

              // ── Topic list ───────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final topic = subject!.topics[i];
                      final color = _colorForIndex(i);
                      return _TopicCard(
                        topic: topic,
                        color: color,
                        emoji: _emojiForTopic(topic),
                        difficultyColor: _difficultyColor(topic.difficulty),
                        difficultyLabel: _difficultyLabel(topic.difficulty),
                        index: i + 1,
                      );
                    },
                    childCount: subject.topics.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }
}

// ── Topic card ────────────────────────────────────────────────────────────────

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.color,
    required this.emoji,
    required this.difficultyColor,
    required this.difficultyLabel,
    required this.index,
  });

  final TopicModel topic;
  final Color color;
  final String emoji;
  final Color difficultyColor;
  final String difficultyLabel;
  final int index;

  int _maxXp() => topic.questions.fold(0, (sum, q) {
        if (q.difficulty == 1) return sum + 10;
        if (q.difficulty == 2) return sum + 15;
        return sum + 20;
      });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed(
        'lesson',
        pathParameters: {'lessonId': topic.id},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Index badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Emoji
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),

              // Topic details
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Difficulty badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            difficultyLabel,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: difficultyColor,
                              fontWeight: FontWeight.w700,
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
                          '⭐ ${_maxXp()} XP',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.xpGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
