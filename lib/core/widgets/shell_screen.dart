import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav_bar.dart';

/// Shell that wraps main screens with the bottom navigation bar.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  /// Returns the bottom nav index for the current route location.
  static int _indexForLocation(String location) {
    if (location.startsWith('/home/leaderboard')) return 3;
    if (location.startsWith('/home/settings')) return 4;
    if (location.startsWith('/home/profile')) return 4; // profile = settings tab
    if (location.startsWith('/home/lesson')) return 1;
    return 0; // home
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.goNamed('home');
            case 1:
              // Lessons tab — navigate home for now, lessons will be added later
              context.goNamed('home');
            case 2:
              // Quiz tab — navigate home for now
              context.goNamed('home');
            case 3:
              context.goNamed('leaderboard');
            case 4:
              context.goNamed('settings');
          }
        },
      ),
    );
  }
}
