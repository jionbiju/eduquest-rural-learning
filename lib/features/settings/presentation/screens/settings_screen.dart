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
import '../../providers/settings_provider.dart';

/// Settings screen — language, sync status, account actions.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _languages = [
    _LangOption('en', 'English', '🇬🇧'),
    _LangOption('hi', 'हिन्दी (Hindi)', '🇮🇳'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(studentProfileProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);
    final pendingSync = ref.watch(pendingSyncCountProvider);
    final connectivityAsync = ref.watch(connectivityProvider);

    final isOnline = connectivityAsync.maybeWhen(
      data: (v) => v,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ── Profile card → taps to full profile ──────────────────────
          GestureDetector(
            onTap: () => context.pushNamed('profile'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  StudentAvatar(
                    name: profile.name,
                    imageUrl: profile.imageUrl,
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.xp} XP · Level ${profile.level} · ${profile.badges.length} badges',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Language selector ─────────────────────────────────────────
          Text('Language / भाषा', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          ...(_languages.map((lang) {
            final isSelected = selectedLang == lang.code;
            return GestureDetector(
              onTap: () {
                ref.read(selectedLanguageProvider.notifier).state = lang.code;
                ref
                    .read(studentProfileProvider.notifier)
                    .updateLanguage(lang.code);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(lang.flag, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lang.label,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.grey800,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      ),
                  ],
                ),
              ),
            );
          })),
          const SizedBox(height: 28),

          // ── Sync status ───────────────────────────────────────────────
          Text('Sync Status', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: isOnline
                      ? Icons.wifi_rounded
                      : Icons.wifi_off_rounded,
                  iconColor: isOnline ? AppColors.success : AppColors.warning,
                  label: isOnline ? 'Connected' : 'Offline',
                  value: isOnline ? 'Online' : 'No internet',
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.sync_rounded,
                  iconColor:
                      pendingSync > 0 ? AppColors.warning : AppColors.success,
                  label: 'Pending sync',
                  value: pendingSync > 0 ? '$pendingSync actions' : 'All synced ✓',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── About ─────────────────────────────────────────────────────
          Text('About', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.school_rounded,
                  iconColor: AppColors.primary,
                  label: 'App',
                  value: 'EduQuest v1.0.0',
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.offline_bolt_rounded,
                  iconColor: AppColors.secondary,
                  label: 'Mode',
                  value: 'Offline-first',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Account ───────────────────────────────────────────────────
          Text('Account', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                // View full profile
                _ActionTile(
                  icon: Icons.person_rounded,
                  label: 'View Profile',
                  iconColor: AppColors.primary,
                  onTap: () => context.pushNamed('profile'),
                ),
                const Divider(height: 1, indent: 56),
                // Sign out
                _SignOutTile(ref: ref),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Sign out tile with confirmation ─────────────────────────────────────────

class _SignOutTile extends ConsumerStatefulWidget {
  const _SignOutTile({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_SignOutTile> createState() => _SignOutTileState();
}

class _SignOutTileState extends ConsumerState<_SignOutTile> {
  bool _loading = false;

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

    setState(() => _loading = true);

    await ref.read(authNotifierProvider.notifier).signOut();
    await ref.read(studentProfileProvider.notifier).clearProfile();

    if (mounted) {
      context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _loading ? null : _signOut,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    )
                  : const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _loading ? 'Signing out…' : 'Sign Out',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            if (!_loading)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.error,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable tiles ───────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(color: iconColor),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption {
  const _LangOption(this.code, this.label, this.flag);
  final String code;
  final String label;
  final String flag;
}
