import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screen imports will be added as screens are built.
// Using placeholder screens until features are scaffolded.

part 'app_routes.dart';

/// Top-level [GoRouter] configuration for EduQuest.
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const _PlaceholderScreen(title: 'Splash'),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
    ),
    GoRoute(
      path: '${AppRoutes.lesson}/:lessonId',
      name: 'lesson',
      builder: (context, state) => _PlaceholderScreen(
        title: 'Lesson ${state.pathParameters['lessonId']}',
      ),
    ),
    GoRoute(
      path: '${AppRoutes.quiz}/:lessonId',
      name: 'quiz',
      builder: (context, state) => _PlaceholderScreen(
        title: 'Quiz ${state.pathParameters['lessonId']}',
      ),
    ),
    GoRoute(
      path: AppRoutes.leaderboard,
      name: 'leaderboard',
      builder: (context, state) => const _PlaceholderScreen(title: 'Leaderboard'),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const _PlaceholderScreen(title: 'Settings'),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);

/// Temporary placeholder used until real screens are wired in.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
