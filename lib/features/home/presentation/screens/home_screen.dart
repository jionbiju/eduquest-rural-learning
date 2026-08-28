import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/connectivity_banner.dart';
import '../../../../core/widgets/xp_progress_bar.dart';
import '../../providers/home_provider.dart';
import '../widgets/daily_quest_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/subject_card.dart';

/// Main home/dashboard screen.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Static subject data — will come from bundle provider later.
  static const _subjects = [
    _SubjectData('Mathematics', '🔢', AppColors.primary, 3),
    _SubjectData('Science', '🔬', AppColors.success, 3),
    _SubjectData('English', '📖', AppColors.secondary, 2),
    _SubjectData('History', '🏛️', AppColors.badgePurple, 2),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(studentProfileProvider);

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
                          onPressed: () {},
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Subject grid ────────────────────────────────────────
                SliverPadding(
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
                        final s = _subjects[index];
                        return SubjectCard(
                          title: s.title,
                          emoji: s.emoji,
                          color: s.color,
                          topicsCount: s.topicsCount,
                          onTap: () => context.goNamed('lesson',
                              pathParameters: {'lessonId': s.title.toLowerCase()}),
                        );
                      },
                      childCount: _subjects.length,
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

/// Simple data holder for subject grid items.
class _SubjectData {
  const _SubjectData(this.title, this.emoji, this.color, this.topicsCount);
  final String title;
  final String emoji;
  final Color color;
  final int topicsCount;
}
