/// App-wide magic strings and configuration values.
abstract final class AppConstants {
  // ── App info ──────────────────────────────────────────────────────────────
  static const String appName = 'EduQuest';
  static const String appVersion = '1.0.0';

  // ── Hive box names ────────────────────────────────────────────────────────
  static const String hiveUserBox = 'user_box';
  static const String hiveLessonsBox = 'lessons_box';
  static const String hiveProgressBox = 'progress_box';
  static const String hiveSyncQueueBox = 'sync_queue_box';
  static const String hiveBundleBox = 'bundle_box';
  static const String hiveSettingsBox = 'settings_box';

  // ── Hive type IDs ─────────────────────────────────────────────────────────
  static const int hiveTypeUserProfile = 0;
  static const int hiveTypeLesson = 1;
  static const int hiveTypeQuestion = 2;
  static const int hiveTypeProgress = 3;
  static const int hiveTypeSyncAction = 4;
  static const int hiveTypeBadge = 5;

  // ── Firestore collections ─────────────────────────────────────────────────
  static const String fsStudents = 'students';
  static const String fsGroups = 'groups';
  static const String fsProgress = 'progress';
  static const String fsProfile = 'profile';
  static const String fsLeaderboard = 'leaderboard';
  static const String fsBundles = 'bundles';

  // ── Gamification defaults ─────────────────────────────────────────────────
  static const int xpPerCorrectAnswer = 10;
  static const int xpPerLessonComplete = 50;
  static const int xpStreakBonus = 20;
  static const int streakResetHours = 48;

  // ── Adaptive difficulty thresholds ────────────────────────────────────────
  /// Rolling accuracy above this → increase difficulty.
  static const double accuracyThresholdUp = 0.75;

  /// Rolling accuracy below this → decrease difficulty.
  static const double accuracyThresholdDown = 0.40;

  /// Window size for rolling accuracy calculation.
  static const int rollingAccuracyWindow = 5;

  // ── Asset paths ───────────────────────────────────────────────────────────
  static const String bundlePath = 'assets/bundles/sample_bundle.json';

  // ── Localization ──────────────────────────────────────────────────────────
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'hi'];

  // ── Sync ──────────────────────────────────────────────────────────────────
  static const int syncBatchSize = 20;
  static const int syncRetryDelaySeconds = 30;
}
