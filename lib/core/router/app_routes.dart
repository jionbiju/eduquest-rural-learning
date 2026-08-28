part of 'app_router.dart';

/// Named route path constants.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  // lesson, quiz, quiz_result are nested under home — use goNamed() with params.
  static const String leaderboard = '/leaderboard';
  static const String settings = '/settings';
}
