import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';

/// Tracks how many quizzes were completed today for the daily quest.
/// Stored in Hive so it persists between app restarts.
/// Resets automatically when the date changes.

class DailyQuestNotifier extends StateNotifier<DailyQuestState> {
  DailyQuestNotifier() : super(_loadFromHive());

  static const _boxKey = 'daily_quest';
  static const _requiredCount = 3; // Complete 3 quizzes for daily quest

  static DailyQuestState _loadFromHive() {
    try {
      final box = Hive.box<String>(AppConstants.hiveSettingsBox);
      final raw = box.get(_boxKey);
      if (raw == null) return DailyQuestState.fresh();

      final parts = raw.split('|');
      if (parts.length != 2) return DailyQuestState.fresh();

      final savedDate = parts[0];
      final count = int.tryParse(parts[1]) ?? 0;
      final today = _todayString();

      // Reset if day changed
      if (savedDate != today) return DailyQuestState.fresh();

      return DailyQuestState(
        date: savedDate,
        completedCount: count,
        requiredCount: _requiredCount,
      );
    } catch (_) {
      return DailyQuestState.fresh();
    }
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _persist() async {
    final box = Hive.box<String>(AppConstants.hiveSettingsBox);
    await box.put(_boxKey, '${state.date}|${state.completedCount}');
  }

  /// Call this whenever a quiz is completed.
  Future<void> recordQuizCompletion() async {
    final today = _todayString();

    // If it's a new day, reset first
    if (state.date != today) {
      state = DailyQuestState.fresh();
    }

    // Increment count (cap at required)
    final newCount = (state.completedCount + 1).clamp(0, _requiredCount);
    state = state.copyWith(completedCount: newCount);
    await _persist();
  }
}

class DailyQuestState {
  const DailyQuestState({
    required this.date,
    required this.completedCount,
    required this.requiredCount,
  });

  final String date;
  final int completedCount;
  final int requiredCount;

  factory DailyQuestState.fresh() {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return DailyQuestState(
      date: today,
      completedCount: 0,
      requiredCount: 3,
    );
  }

  double get progress =>
      requiredCount > 0 ? completedCount / requiredCount : 0.0;

  bool get isCompleted => completedCount >= requiredCount;

  String get questTitle => 'Complete $requiredCount quizzes today';

  String get progressLabel => '$completedCount / $requiredCount quizzes done';

  DailyQuestState copyWith({
    String? date,
    int? completedCount,
    int? requiredCount,
  }) {
    return DailyQuestState(
      date: date ?? this.date,
      completedCount: completedCount ?? this.completedCount,
      requiredCount: requiredCount ?? this.requiredCount,
    );
  }
}

/// Provider for the daily quest state.
final dailyQuestProvider =
    StateNotifierProvider<DailyQuestNotifier, DailyQuestState>(
  (ref) => DailyQuestNotifier(),
);

/// Provider that checks if today's streak should be updated.
/// Returns true if the user completed at least 1 quiz today and
/// hasn't had their streak updated yet today.
final streakTrackerProvider = StateNotifierProvider<StreakTracker, String>(
  (ref) => StreakTracker(),
);

class StreakTracker extends StateNotifier<String> {
  StreakTracker() : super(_loadLastStreakDate());

  static const _key = 'last_streak_date';

  static String _loadLastStreakDate() {
    try {
      final box = Hive.box<String>(AppConstants.hiveSettingsBox);
      return box.get(_key) ?? '';
    } catch (_) {
      return '';
    }
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Returns true if streak was just incremented (first quiz today).
  /// Returns false if streak was already counted today.
  Future<bool> tryIncrementStreak() async {
    final today = _todayString();
    if (state == today) return false; // Already counted today

    state = today;
    try {
      final box = Hive.box<String>(AppConstants.hiveSettingsBox);
      await box.put(_key, today);
    } catch (_) {}
    return true;
  }
}
