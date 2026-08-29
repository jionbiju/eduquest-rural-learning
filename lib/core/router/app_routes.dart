part of 'app_router.dart';

/// Named route path constants.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String leaderboard = '/home/leaderboard';
  static const String settings = '/home/settings';
  static const String profile = '/home/profile';
  // lesson, quiz, quiz_result are nested under home — use goNamed() with params.
}
