import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/connectivity_banner.dart';
import '../../../../core/widgets/xp_progress_bar.dart';
import '../../../lessons/data/models/subject_model.dart';
import '../../../lessons/data/repositories/bundle_repository.dart';
import '../../providers/home_provider.dart';
import '../widgets/daily_quest_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/subject_card.dart';

/// Main home/dashboard screen.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _subjectColors = [
    AppColors.primary,
    AppColors.success,
    AppColors.secondary,
    AppColors.badgePurple,
    AppColors.xpGold,
    AppColors.primary,
  ];

  static const _subjectEmojis = <String, String>{
    'math': '🔢',
    'science': '🔬',
    'english': '📖',
    'history': '🏛️',
    'geography': '🌍',
  };

  Color _colorForIndex(int i) =>
      _subjectColors[i % _subjectColors.length];

  String _emojiForSubject(SubjectModel subject) {
    for (final entry in _subjectEmojis.entries) {
      if (subject.id.startsWith(entry.key)) return entry.value;
    }
    return '📚';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(studentProfileProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Offline banner sits above everything
          const ConnectivityBanner(isOnline: true),

          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Header (gradient card) ──────────────────────────────
                SliverToBoxAdapter(
                  child: HomeHeader(profile: profile),
                ),

                // ── XP Progress bar ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: XpProgressBar(
                      level: profile.level,
                      progress: profile.levelProgress,
                      xp: profile.xp,
                    ),
                  ),
                ),

                // ── Daily Quest Banner ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: DailyQuestBanner(
                      questTitle: 'Complete 3 Math quizzes',
                      progress: 0.4,
                      onTap: () => context.goNamed('lesson',
                          pathParameters: {'lessonId': 'math_addition'}),
                    ),
                  ),
                ),

                // ── Section title ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subjects',
                          style: AppTextStyles.headlineMedium,
                        ),
                        TextButton(
                          onPressed: () => context.goNamed('lessons'),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Subject grid (from bundle) ───────────────────────────
                subjectsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (_, __) => const SliverToBoxAdapter(
                    child: SizedBox.shrink(),
                  ),
                  data: (subjects) => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.05,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final subject = subjects[index];
                          final color = _colorForIndex(index);
                          return SubjectCard(
                            title: subject.localizedName('en'),
                            emoji: _emojiForSubject(subject),
                            color: color,
                            topicsCount: subject.topics.length,
                            onTap: () => context.goNamed(
                              'subject_topics',
                              pathParameters: {'subjectId': subject.id},
                            ),
                          );
                        },
                        childCount: subjects.length,
                      ),
                    ),
                  ),
                ),

                // ── Bottom padding for nav bar ──────────────────────────
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
