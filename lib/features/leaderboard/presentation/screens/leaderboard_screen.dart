import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/providers/home_provider.dart';
import '../../data/models/leaderboard_entry.dart';
import '../../providers/leaderboard_provider.dart';
import '../widgets/leaderboard_tile.dart';
import '../widgets/podium_widget.dart';

/// Leaderboard screen showing real student data from Firestore.
/// Falls back to mock data when offline.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    // Get the current user's ID from local profile (tied to Firebase UID).
    final profile = ref.watch(studentProfileProvider);
    final currentStudentId = profile.id;

    final isFirebaseReady = FirebaseService.isInitialised;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          // Invalidate provider to trigger a fresh fetch.
          ref.invalidate(leaderboardProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: Text(
                'Leaderboard',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              actions: [
                // Online/offline badge
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Icon(
                        isFirebaseReady
                            ? Icons.cloud_done_rounded
                            : Icons.cloud_off_rounded,
                        size: 16,
                        color: isFirebaseReady
                            ? Colors.greenAccent
                            : Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isFirebaseReady ? 'Live' : 'Offline',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isFirebaseReady
                              ? Colors.greenAccent
                              : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            leaderboardAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading leaderboard…'),
                    ],
                  ),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: _ErrorView(onRetry: () {
                  ref.invalidate(leaderboardProvider);
                }),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyView(isOffline: !isFirebaseReady),
                  );
                }

                return SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Offline banner ───────────────────────────────
                    if (!isFirebaseReady)
                      _OfflineBanner(),

                    // ── Podium (top 3) ───────────────────────────────
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryDark,
                            AppColors.primary,
                          ],
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
                            currentStudentId: currentStudentId,
                          ),
                        ],
                      ),
                    ),

                    // ── My rank banner ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _MyRankBanner(
                        entries: entries,
                        currentStudentId: currentStudentId,
                      ),
                    ),

                    // ── Full ranked list ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'All Students',
                            style: AppTextStyles.headlineSmall,
                          ),
                          Text(
                            '${entries.length} enrolled',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: entries
                            .map(
                              (e) => LeaderboardTile(
                                entry: e,
                                isCurrentUser:
                                    e.studentId == currentStudentId,
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    // Pull-to-refresh hint
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Pull down to refresh',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.grey400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── My rank banner ───────────────────────────────────────────────────────────

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

    final isTopThree = myEntry.rank <= 3;
    final rankEmoji = switch (myEntry.rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '⭐',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTopThree
            ? AppColors.xpGold.withValues(alpha: 0.12)
            : AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTopThree ? AppColors.xpGold : AppColors.secondary,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(rankEmoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Rank',
                  style: AppTextStyles.labelMedium,
                ),
                Text(
                  '#${myEntry.rank} · ${myEntry.xp} XP',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isTopThree
                        ? AppColors.secondaryDark
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Lvl ${myEntry.level}',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Offline banner ────────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offline — showing cached data. Pull to refresh when online.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.isOffline});
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📊', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              isOffline ? 'You\'re Offline' : 'No students yet',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              isOffline
                  ? 'Connect to the internet to see the leaderboard.'
                  : 'Complete lessons to appear on the leaderboard!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Could not load leaderboard',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
