import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../features/auth/data/models/auth_user.dart';
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
import '../../features/teacher_content/presentation/screens/teacher_dashboard_screen.dart';
import '../widgets/shell_screen.dart';

part 'app_routes.dart';

/// Returns true if a user is authenticated (either student or teacher)
bool _hasProfile() {
  try {
    final box = Hive.box<String>(AppConstants.hiveUserBox);
    // Check for authUser (new) or profile (legacy student-only)
    return box.get('authUser') != null || box.get('profile') != null;
  } catch (_) {
    return false;
  }
}

/// Get user role from stored auth data
UserRole? _getUserRole() {
  try {
    final box = Hive.box<String>(AppConstants.hiveUserBox);
    
    // First check for authUser (contains role)
    final authUserJson = box.get('authUser');
    if (authUserJson != null) {
      final decoded = jsonDecode(authUserJson) as Map<String, dynamic>;
      final roleString = decoded['role'] as String?;
      if (roleString != null) {
        return UserRole.fromJson(roleString);
      }
    }
    
    // Fallback: check for old profile format (student-only)
    final profileJson = box.get('profile');
    if (profileJson != null) {
      return UserRole.student;
    }
    
    return null;
  } catch (e) {
    debugPrint('❌ Error getting user role: $e');
    return null;
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
    final onTeacherDashboard = state.matchedLocation == AppRoutes.teacherDashboard;

    // Always let splash, login, signup, and forgot password through.
    if (onSplash || onLogin || onSignup || onForgotPassword) return null;

    // Check if user has a profile
    if (!_hasProfile()) return AppRoutes.login;

    // Role-based routing: redirect teachers to dashboard, students to home
    final userRole = _getUserRole();
    
    if (userRole == UserRole.teacher) {
      // Teacher trying to access student routes -> redirect to teacher dashboard
      if (!onTeacherDashboard && !state.matchedLocation.startsWith('/teacher')) {
        return AppRoutes.teacherDashboard;
      }
    } else {
      // Student trying to access teacher routes -> redirect to home
      if (onTeacherDashboard || state.matchedLocation.startsWith('/teacher')) {
        return AppRoutes.home;
      }
    }

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

    // ── TEACHER ROUTES ────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.teacherDashboard,
      name: 'teacher_dashboard',
      builder: (context, state) => const TeacherDashboardScreen(),
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
                        // Guard against null extra — happens on hot reload
                        // or browser back/forward navigation.
                        final raw = state.extra;
                        if (raw == null || raw is! Map<String, dynamic>) {
                          // No data — go back to quiz hub safely
                          return const _QuizResultFallback();
                        }
                        final extra = raw;
                        return QuizResultScreen(
                          correctCount:
                              (extra['correctCount'] as num?)?.toInt() ?? 0,
                          totalQuestions:
                              (extra['totalQuestions'] as num?)?.toInt() ?? 0,
                          xpEarned:
                              (extra['xpEarned'] as num?)?.toInt() ?? 0,
                          topicId: extra['topicId'] as String? ?? '',
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

/// Shown when quiz result route is accessed without data (e.g. hot reload).
class _QuizResultFallback extends StatelessWidget {
  const _QuizResultFallback();

  @override
  Widget build(BuildContext context) {
    // Redirect to quiz hub after one frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.goNamed('quiz_hub');
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
