import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/lessons/presentation/screens/lesson_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/quiz/presentation/screens/quiz_result_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

part 'app_routes.dart';

/// Top-level [GoRouter] configuration for EduQuest.
/// lesson and quiz are nested under home so back navigation works correctly.
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        // Lesson nested under home — back button returns to home.
        GoRoute(
          path: 'lesson/:lessonId',
          name: 'lesson',
          builder: (context, state) => LessonScreen(
            topicId: state.pathParameters['lessonId'] ?? '',
          ),
          routes: [
            // Quiz nested under lesson — back button returns to lesson.
            GoRoute(
              path: 'quiz',
              name: 'quiz',
              builder: (context, state) => QuizScreen(
                topicId: state.pathParameters['lessonId'] ?? '',
              ),
              routes: [
                // Result nested under quiz — back goes to home via goNamed.
                GoRoute(
                  path: 'result',
                  name: 'quiz_result',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return QuizResultScreen(
                      correctCount: extra['correctCount'] as int,
                      totalQuestions: extra['totalQuestions'] as int,
                      xpEarned: extra['xpEarned'] as int,
                      topicId: extra['topicId'] as String,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.leaderboard,
      name: 'leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
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
