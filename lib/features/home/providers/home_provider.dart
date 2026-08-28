import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../data/models/student_profile.dart';

/// Provides the current student profile backed by Hive.
final studentProfileProvider =
    StateNotifierProvider<StudentProfileNotifier, StudentProfile>(
  (ref) => StudentProfileNotifier(),
);

/// Returns true if a profile already exists in Hive (skip login).
final hasExistingProfileProvider = Provider<bool>((ref) {
  final box = Hive.box<String>(AppConstants.hiveUserBox);
  return box.get('profile') != null;
});

class StudentProfileNotifier extends StateNotifier<StudentProfile> {
  StudentProfileNotifier() : super(_loadFromHive() ?? _defaultProfile()) {
    // Persist whenever state changes.
  }

  /// Loads profile from Hive on startup.
  static StudentProfile? _loadFromHive() {
    try {
      final box = Hive.box<String>(AppConstants.hiveUserBox);
      final raw = box.get('profile');
      if (raw == null) return null;
      return StudentProfile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static StudentProfile _defaultProfile() => const StudentProfile(
        id: 'guest',
        name: 'Student',
        groupId: 'group_01',
      );

  Future<void> _persist() async {
    final box = Hive.box<String>(AppConstants.hiveUserBox);
    await box.put('profile', jsonEncode(state.toJson()));
  }

  /// Creates a new profile from the login form and persists it.
  Future<void> createProfile({
    required String name,
    required String studentId,
    required String language,
  }) async {
    state = StudentProfile(
      id: studentId.isNotEmpty ? studentId : const Uuid().v4(),
      name: name,
      groupId: 'group_village_01',
      xp: 0,
      streak: 0,
      badges: const [],
      language: language,
    );
    await _persist();
  }

  void addXp(int amount) {
    state = state.copyWith(xp: state.xp + amount);
    _persist();
  }

  void incrementStreak() {
    state = state.copyWith(streak: state.streak + 1);
    _persist();
  }

  void earnBadge(String badgeId) {
    if (!state.badges.contains(badgeId)) {
      state = state.copyWith(badges: [...state.badges, badgeId]);
      _persist();
    }
  }

  void updateLanguage(String lang) {
    state = state.copyWith(language: lang);
    _persist();
  }
}
