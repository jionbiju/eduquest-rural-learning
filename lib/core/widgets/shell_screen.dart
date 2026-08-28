import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav_bar.dart';

/// Shell that wraps main screens with the bottom navigation bar.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  static int _indexForLocation(String location) {
    if (location.startsWith('/home/leaderboard')) return 3;
    if (location.startsWith('/home/settings')) return 4;
    if (location.startsWith('/home/lessons')) return 1;
    if (location.startsWith('/home/quests')) return 2;
    return 0;
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
              context.go('/home');
            case 1:
              // Lessons tab — go to first subject for now
              context.go('/home');
            case 2:
              // Quiz tab — go home for now
              context.go('/home');
            case 3:
              context.go('/home/leaderboard');
            case 4:
              context.go('/home/settings');
          }
        },
      ),
    );
  }
}
