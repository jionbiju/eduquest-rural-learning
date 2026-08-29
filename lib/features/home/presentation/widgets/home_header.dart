import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/student_avatar.dart';
import '../../../../core/widgets/xp_chip.dart';
import '../../../../core/widgets/streak_chip.dart';
import '../../../../core/widgets/game_widgets.dart';
import '../../data/models/student_profile.dart';

/// EPIC HERO HEADER - Space-themed with floating particles and glow effects
class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key, required this.profile});

  final StudentProfile profile;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅 Rise & Conquer';
    if (hour < 17) return '⚔️ Battle On';
    return '🌙 Night Quest';
  }

  String get _subGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Ready for today\'s challenges?';
    if (hour < 17) return 'Keep pushing forward, hero!';
    return 'Time to shine in the darkness!';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated gradient background
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.nebulaGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
        // Floating particles overlay
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: const FloatingParticles(
              particleCount: 30,
              colors: [
                AppColors.cosmicBlue,
                AppColors.cosmicPurple,
                AppColors.cosmicPink,
              ],
            ),
          ),
        ),
        // Shimmer overlay effect
        AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.1 * _shimmerController.value),
                    Colors.white.withOpacity(0.0),
                  ],
                  stops: [
                    _shimmerController.value - 0.3,
                    _shimmerController.value,
                    _shimmerController.value + 0.3,
                  ],
                ),
              ),
            );
          },
        ),
        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar + notification
              Row(
                children: [
                  // Epic glowing avatar
                  PulsingBadge(
                    size: 64,
                    color: AppColors.xpGold,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: StudentAvatar(
                        name: widget.profile.name,
                        imageUrl: widget.profile.imageUrl,
                        radius: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.xpGold,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.profile.name,
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subGreeting,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification with pulse
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.cosmicPink.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Stack(
                        children: [
                          const Icon(
                            Icons.notifications_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.streakFire,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.streakFire,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Stats row with glow effects
              Row(
                children: [
                  Expanded(
                    child: _GlowingStat(
                      icon: '⭐',
                      label: 'XP',
                      value: '${widget.profile.xp}',
                      gradient: AppColors.legendaryGradient,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GlowingStat(
                      icon: '🔥',
                      label: 'Streak',
                      value: '${widget.profile.streak}',
                      gradient: AppColors.questGradient,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GlowingStat(
                      icon: '🏆',
                      label: 'Badges',
                      value: '${widget.profile.badges.length}',
                      gradient: AppColors.victoryGradient,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Glowing stat card
class _GlowingStat extends StatelessWidget {
  const _GlowingStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  final String icon;
  final String label;
  final String value;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
