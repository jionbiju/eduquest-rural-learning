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
          color: const Color(0xFFC0C0C0),
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
          color: const Color(0xFFCD7F32),
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
        Text(crownEmoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        // Avatar with highlight if current user
        Container(
          decoration: isCurrentUser
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 12,
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
        Text(
          entry.name.split(' ').first,
          style: AppTextStyles.labelMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${entry.xp} XP',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
        const SizedBox(height: 6),
        // Podium block
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: AppTextStyles.headlineMedium.copyWith(color: color),
            ),
          ),
        ),
      ],
    );
  }
}
