import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/student_avatar.dart';
import '../../data/models/leaderboard_entry.dart';

/// Displays the top 3 students in a podium layout.
class PodiumWidget extends StatelessWidget {
  const PodiumWidget({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    required this.currentStudentId,
  });

  final LeaderboardEntry first;
  final LeaderboardEntry second;
  final LeaderboardEntry third;
  final String currentStudentId;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 2nd place
        _PodiumColumn(
          entry: second,
          height: 90,
          crownEmoji: '🥈',
          color: const Color(0xFFE2E8F0),
          isCurrentUser: second.studentId == currentStudentId,
        ),
        const SizedBox(width: 12),
        // 1st place — tallest
        _PodiumColumn(
          entry: first,
          height: 120,
          crownEmoji: '🥇',
          color: AppColors.xpGold,
          isCurrentUser: first.studentId == currentStudentId,
        ),
        const SizedBox(width: 12),
        // 3rd place
        _PodiumColumn(
          entry: third,
          height: 70,
          crownEmoji: '🥉',
          color: const Color(0xFFFDBA74),
          isCurrentUser: third.studentId == currentStudentId,
        ),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.entry,
    required this.height,
    required this.crownEmoji,
    required this.color,
    required this.isCurrentUser,
  });

  final LeaderboardEntry entry;
  final double height;
  final String crownEmoji;
  final Color color;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown emoji
        Text(crownEmoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        // Avatar with highlight if current user
        Container(
          decoration: isCurrentUser
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.xpGold, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.xpGold.withValues(alpha: 0.6),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: StudentAvatar(
            name: entry.name,
            radius: 28,
            showBorder: isCurrentUser,
          ),
        ),
        const SizedBox(height: 6),
        // Student Name in high contrast white
        Text(
          entry.name.split(' ').first,
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        // High contrast XP Chip on dark podium background
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 10)),
              const SizedBox(width: 3),
              Text(
                '${entry.xp} XP',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.xpGold,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Podium block
        Container(
          width: 84,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.22),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#${entry.rank}',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
