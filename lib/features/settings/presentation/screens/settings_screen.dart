import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/student_avatar.dart';
import '../../../home/providers/home_provider.dart';
import '../../../sync/providers/sync_provider.dart';
import '../../providers/settings_provider.dart';

/// Settings screen — language selector, profile info, sync status.
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
          // ── Profile card ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              children: [
                StudentAvatar(name: profile.name, radius: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: AppTextStyles.headlineSmall),
                      Text(
                        'Group: ${profile.groupId}',
                        style: AppTextStyles.bodySmall,
                      ),
                      Text(
                        '${profile.xp} XP · Level ${profile.level}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Language selector ─────────────────────────────────────────
          Text('Language / भाषा', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          ...(_languages.map((lang) {
            final isSelected = selectedLang == lang.code;
            return GestureDetector(
              onTap: () => ref
                  .read(selectedLanguageProvider.notifier)
                  .state = lang.code,
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
                    color:
                        isSelected ? AppColors.primary : AppColors.grey200,
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
          const SizedBox(height: 24),

          // ── Sync status ───────────────────────────────────────────────
          Text('Sync Status', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                // ignore: prefer_const_constructors
                _StatusRow(
                  icon: isOnline
                      ? Icons.wifi_rounded
                      : Icons.wifi_off_rounded,
                  iconColor:
                      isOnline ? AppColors.success : AppColors.warning,
                  // ignore: prefer_const_literals_to_create_immutables
                  label: isOnline ? 'Connected' : 'Offline',
                  value: isOnline ? 'Online' : 'No internet',
                ),
                const Divider(height: 20),
                _StatusRow(
                  icon: Icons.sync_rounded,
                  iconColor: pendingSync > 0
                      ? AppColors.warning
                      : AppColors.success,
                  label: 'Pending sync',
                  value: pendingSync > 0
                      ? '$pendingSync actions'
                      : 'All synced ✓',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── App info ──────────────────────────────────────────────────
          Text('About', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                _StatusRow(
                  icon: Icons.school_rounded,
                  iconColor: AppColors.primary,
                  label: 'App',
                  value: 'EduQuest v1.0.0',
                ),
                const Divider(height: 20),
                _StatusRow(
                  icon: Icons.offline_bolt_rounded,
                  iconColor: AppColors.secondary,
                  label: 'Mode',
                  value: 'Offline-first',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  _StatusRow({
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
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(color: iconColor),
        ),
      ],
    );
  }
}

class _LangOption {
  const _LangOption(this.code, this.label, this.flag);
  final String code;
  final String label;
  final String flag;
}
