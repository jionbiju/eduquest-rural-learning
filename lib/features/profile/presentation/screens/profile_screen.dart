// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/student_avatar.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../home/providers/home_provider.dart';
import '../../../sync/providers/sync_provider.dart';

/// Full profile screen showing stats, badges, edit options and sign out.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSigningOut = false;

  // ── Badge metadata ───────────────────────────────────────────────────────
  static const _badgeMeta = {
    'first_lesson': ('🎯', 'First Lesson', 'Completed your first lesson'),
    'streak_3': ('🔥', '3-Day Streak', 'Studied 3 days in a row'),
    'streak_7': ('⚡', '7-Day Streak', 'Studied 7 days in a row'),
    'quiz_master': ('🏆', 'Quiz Master', 'Scored 100% on a quiz'),
    'speedrun': ('💨', 'Speed Run', 'Finished a quiz in under 2 minutes'),
    'all_correct': ('⭐', 'Perfect Score', 'All questions correct in a topic'),
  };

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Sign Out?'),
        content: const Text(
          'Your progress is saved. You can sign back in anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSigningOut = true);

    // Sign out from Firebase
    await ref.read(authNotifierProvider.notifier).signOut();

    // Clear local Hive profile
    await ref.read(studentProfileProvider.notifier).clearProfile();

    if (mounted) {
      context.goNamed('login');
    }
  }

  void _showEditNameDialog() {
    final profile = ref.read(studentProfileProvider);
    final controller = TextEditingController(text: profile.name);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref
                    .read(studentProfileProvider.notifier)
                    .updateName(newName);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(studentProfileProvider);
    final pendingSync = ref.watch(pendingSyncCountProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final isOnline = connectivityAsync.maybeWhen(
      data: (v) => v,
      orElse: () => false,
    );

    // XP needed to reach next level
    final xpInLevel = profile.xp % 500;
    final xpToNext = 500 - xpInLevel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                tooltip: 'Edit name',
                onPressed: _showEditNameDialog,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      // Avatar
                      Stack(
                        children: [
                          StudentAvatar(
                            name: profile.name,
                            imageUrl: profile.imageUrl,
                            radius: 48,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showEditNameDialog,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.name,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${profile.level} · ${profile.groupId}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── XP & Stats row ──────────────────────────────────
                  _SectionLabel('Stats'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatCard(
                        emoji: '⭐',
                        label: 'Total XP',
                        value: '${profile.xp}',
                        color: AppColors.xpGold,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        emoji: '🔥',
                        label: 'Streak',
                        value: '${profile.streak} days',
                        color: AppColors.streakOrange,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        emoji: '🏅',
                        label: 'Badges',
                        value: '${profile.badges.length}',
                        color: AppColors.badgePurple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Level progress ───────────────────────────────────
                  _SectionLabel('Level Progress'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Level ${profile.level}',
                              style: AppTextStyles.headlineSmall,
                            ),
                            Text(
                              'Level ${profile.level + 1}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: profile.levelProgress,
                            ),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOut,
                            builder: (_, v, __) => LinearProgressIndicator(
                              value: v,
                              minHeight: 14,
                              backgroundColor: AppColors.grey100,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.xpGold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$xpInLevel / 500 XP',
                              style: AppTextStyles.bodySmall,
                            ),
                            Text(
                              '$xpToNext XP to next level',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Badges ───────────────────────────────────────────
                  _SectionLabel('Badges Earned (${profile.badges.length})'),
                  const SizedBox(height: 12),
                  profile.badges.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                const Text(
                                  '🎖️',
                                  style: TextStyle(fontSize: 40),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No badges yet',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.grey600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Complete lessons to earn badges!',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: profile.badges.map((id) {
                            final meta = _badgeMeta[id] ??
                                ('🏅', id, 'Achievement unlocked');
                            return _BadgeCard(
                              emoji: meta.$1,
                              title: meta.$2,
                              description: meta.$3,
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),

                  // ── Account info ─────────────────────────────────────
                  _SectionLabel('Account'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      children: [
                        _InfoTile(
                          icon: Icons.badge_outlined,
                          label: 'Student ID',
                          value: profile.id.length > 20
                              ? '${profile.id.substring(0, 20)}…'
                              : profile.id,
                        ),
                        const Divider(height: 1, indent: 56),
                        _InfoTile(
                          icon: Icons.group_outlined,
                          label: 'Group',
                          value: profile.groupId,
                        ),
                        const Divider(height: 1, indent: 56),
                        _InfoTile(
                          icon: Icons.language_rounded,
                          label: 'Language',
                          value: profile.language == 'hi'
                              ? 'हिन्दी (Hindi)'
                              : 'English',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Sync status ──────────────────────────────────────
                  _SectionLabel('Sync Status'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      children: [
                        _InfoTile(
                          icon: isOnline
                              ? Icons.wifi_rounded
                              : Icons.wifi_off_rounded,
                          iconColor: isOnline
                              ? AppColors.success
                              : AppColors.warning,
                          label: 'Connection',
                          value: isOnline ? 'Online' : 'Offline',
                        ),
                        const Divider(height: 1, indent: 56),
                        _InfoTile(
                          icon: Icons.sync_rounded,
                          iconColor: pendingSync > 0
                              ? AppColors.warning
                              : AppColors.success,
                          label: 'Pending Sync',
                          value: pendingSync > 0
                              ? '$pendingSync actions waiting'
                              : 'All synced ✓',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Sign out button ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isSigningOut ? null : _signOut,
                      icon: _isSigningOut
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : const Icon(Icons.logout_rounded),
                      label: Text(
                        _isSigningOut ? 'Signing out…' : 'Sign Out',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.headlineSmall);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String emoji;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.badgePurple.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.badgePurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.badgePurple,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppColors.grey400, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
