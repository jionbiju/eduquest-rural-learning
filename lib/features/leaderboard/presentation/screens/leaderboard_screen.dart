import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/leaderboard_entry.dart';
import '../../providers/leaderboard_provider.dart';
import '../widgets/leaderboard_tile.dart';
import '../widgets/podium_widget.dart';

/// Leaderboard screen scoped to the student's class/village group.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  // Current student ID — will come from auth provider later.
  static const _currentStudentId = 'student_001';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(
              'Class Leaderboard',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    const Icon(Icons.group_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Village Group 1',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          leaderboardAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error loading leaderboard: $e')),
            ),
            data: (entries) {
              if (entries.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No students yet.')),
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  // ── Podium (top 3) ──────────────────────────────────
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🏆 Top Students',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        PodiumWidget(
                          first: entries[0],
                          second: entries.length > 1
                              ? entries[1]
                              : entries[0],
                          third: entries.length > 2
                              ? entries[2]
                              : entries[0],
                          currentStudentId: _currentStudentId,
                        ),
                      ],
                    ),
                  ),

                  // ── My rank highlight ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _MyRankBanner(
                      entries: entries,
                      currentStudentId: _currentStudentId,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Full list (rank 4+) ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'All Students',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: entries
                          .map(
                            (e) => LeaderboardTile(
                              entry: e,
                              isCurrentUser:
                                  e.studentId == _currentStudentId,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Banner showing the current student's rank at a glance.
class _MyRankBanner extends StatelessWidget {
  const _MyRankBanner({
    required this.entries,
    required this.currentStudentId,
  });

  final List<LeaderboardEntry> entries;
  final String currentStudentId;

  @override
  Widget build(BuildContext context) {
    LeaderboardEntry? myEntry;
    try {
      myEntry = entries.firstWhere(
        (e) => e.studentId == currentStudentId,
      );
    } catch (_) {
      myEntry = null;
    }

    if (myEntry == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your rank: #${myEntry.rank} with ${myEntry.xp} XP',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.secondaryDark,
              ),
            ),
          ),
          Text(
            'Lvl ${myEntry.level}',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
