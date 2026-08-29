import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/lessons/presentation/screens/lesson_screen.dart';
import '../../features/lessons/presentation/screens/lessons_list_screen.dart';
import '../../features/lessons/presentation/screens/subject_topics_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/quiz/presentation/screens/quiz_hub_screen.dart';
import '../../features/quiz/presentation/screens/quiz_result_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/shell_screen.dart';

part 'app_routes.dart';

/// Returns true if a student profile exists in Hive.
bool _hasProfile() {
  try {
    final box = Hive.box<String>(AppConstants.hiveUserBox);
    return box.get('profile') != null;
  } catch (_) {
    return false;
  }
}

/// Top-level [GoRouter] for EduQuest.
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final onSplash = state.matchedLocation == AppRoutes.splash;
    final onLogin = state.matchedLocation == AppRoutes.login;
    final onSignup = state.matchedLocation == AppRoutes.signup;
    final onForgotPassword = state.matchedLocation == AppRoutes.forgotPassword;

    // Always let splash, login, signup, and forgot password through.
    if (onSplash || onLogin || onSignup || onForgotPassword) return null;

    // Any other route — redirect to login if no profile.
    if (!_hasProfile()) return AppRoutes.login;

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ── Shell wraps all main screens with bottom nav ──────────────────
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'lesson/:lessonId',
              name: 'lesson',
              builder: (context, state) => LessonScreen(
                topicId: state.pathParameters['lessonId'] ?? '',
              ),
              routes: [
                GoRoute(
                  path: 'quiz',
                  name: 'quiz',
                  builder: (context, state) => QuizScreen(
                    topicId: state.pathParameters['lessonId'] ?? '',
                  ),
                  routes: [
                    GoRoute(
                      path: 'result',
                      name: 'quiz_result',
                      builder: (context, state) {
                        final extra =
                            state.extra as Map<String, dynamic>;
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
            GoRoute(
              path: 'subject/:subjectId',
              name: 'subject_topics',
              builder: (context, state) => SubjectTopicsScreen(
                subjectId: state.pathParameters['subjectId'] ?? '',
              ),
            ),
            GoRoute(
              path: 'lessons',
              name: 'lessons',
              builder: (context, state) => const LessonsListScreen(),
            ),
            GoRoute(
              path: 'quiz_hub',
              name: 'quiz_hub',
              builder: (context, state) => const QuizHubScreen(),
            ),
            GoRoute(
              path: 'leaderboard',
              name: 'leaderboard',
              builder: (context, state) => const LeaderboardScreen(),
            ),
            GoRoute(
              path: 'settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: 'profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.error}')),
  ),
);
