import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Animated floating XP reward that bounces up and fades out.
class XpRewardPopup extends StatefulWidget {
  const XpRewardPopup({super.key, required this.xp});

  final int xp;

  @override
  State<XpRewardPopup> createState() => _XpRewardPopupState();
}

class _XpRewardPopupState extends State<XpRewardPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);

    _translateY = Tween(begin: 0.0, end: -60.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 1.2)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 40),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
    ]).animate(_ctrl);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _translateY.value),
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.xpGold,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.xpGold.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text(
                      '+${widget.xp} XP',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
