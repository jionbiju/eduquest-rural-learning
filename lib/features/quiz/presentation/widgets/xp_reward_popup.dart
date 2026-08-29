import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// EPIC XP REWARD POPUP - Explosive animation with particles and glow
class XpRewardPopup extends StatefulWidget {
  const XpRewardPopup({super.key, required this.xp});

  final int xp;

  @override
  State<XpRewardPopup> createState() => _XpRewardPopupState();
}

class _XpRewardPopupState extends State<XpRewardPopup>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _particleCtrl;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_mainCtrl);

    _translateY = Tween(begin: 20.0, end: -80.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOutCubic),
    );

    _scale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.4)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
    ]).animate(_mainCtrl);

    _rotation = Tween(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _mainCtrl.forward();
    _particleCtrl.repeat();
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainCtrl, _particleCtrl]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _translateY.value),
          child: Opacity(
            opacity: _opacity.value,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Particle burst effect
                if (_mainCtrl.value < 0.6)
                  ..._buildParticles(),
                // Main XP badge
                Transform.scale(
                  scale: _scale.value,
                  child: Transform.rotate(
                    angle: _rotation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.legendaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.xpGold.withOpacity(0.7),
                            blurRadius: 24 + (_mainCtrl.value * 10),
                            spreadRadius: 6 + (_mainCtrl.value * 4),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 16,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '⭐',
                            style: TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${widget.xp} XP',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildParticles() {
    final particles = <Widget>[];
    for (int i = 0; i < 8; i++) {
      final angle = (i * 3.14159 * 2) / 8;
      final distance = 60.0 * _particleCtrl.value;
      final x = distance * (i % 2 == 0 ? 1 : -1) * (i ~/ 2);
      final y = distance * ((i + 1) % 2 == 0 ? 1 : -1);

      particles.add(
        Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: 1 - _particleCtrl.value,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    i % 2 == 0 ? AppColors.xpGold : AppColors.cosmicPink,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return particles;
  }
}
