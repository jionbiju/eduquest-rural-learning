import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// EPIC BOTTOM NAV - Game-style navigation with glow effects
class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
      gradient: AppColors.heroGradient,
    ),
    _NavItem(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Lessons',
      gradient: AppColors.victoryGradient,
    ),
    _NavItem(
      icon: Icons.quiz_outlined,
      selectedIcon: Icons.quiz_rounded,
      label: 'Quiz',
      gradient: AppColors.questGradient,
    ),
    _NavItem(
      icon: Icons.leaderboard_outlined,
      selectedIcon: Icons.leaderboard_rounded,
      label: 'Ranks',
      gradient: AppColors.legendaryGradient,
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
      gradient: AppColors.nebulaGradient,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (index) => Expanded(
                child: _NavButton(
                  item: _items[index],
                  isSelected: widget.currentIndex == index,
                  onTap: () => widget.onTap(index),
                  glowAnimation: _glowController,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final List<Color> gradient;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.gradient,
  });
}

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.glowAnimation,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double> glowAnimation;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: widget.glowAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: widget.isSelected
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.item.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.item.gradient.first.withOpacity(
                              0.4 + (widget.glowAnimation.value * 0.2)),
                          blurRadius: 12 + (widget.glowAnimation.value * 6),
                          spreadRadius: 2 + (widget.glowAnimation.value * 1),
                        ),
                      ],
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isSelected ? widget.item.selectedIcon : widget.item.icon,
                    color: widget.isSelected
                        ? Colors.white
                        : AppColors.grey600,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: widget.isSelected
                          ? FontWeight.w900
                          : FontWeight.w600,
                      color: widget.isSelected
                          ? Colors.white
                          : AppColors.grey600,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
