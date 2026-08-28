import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Thin banner shown at the top of screens when the device is offline.
/// Animates in/out based on [isOnline].
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      height: isOnline ? 0 : 36,
      color: AppColors.warning,
      child: isOnline
          ? const SizedBox.shrink()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'You are offline — progress saves locally',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }
}
