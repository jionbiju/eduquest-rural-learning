import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/sync/data/repositories/firestore_repository.dart';
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
  StudentProfileNotifier() : super(_loadFromHive() ?? _defaultProfile());

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

  /// Called on login/signup.
  ///
  /// Priority order for restoring progress:
  ///   1. If Hive has a profile for this exact UID → keep it (fastest, offline)
  ///   2. Else fetch from Firestore → restore XP/streak/badges from cloud
  ///   3. Else create a brand-new profile (first ever sign-up)
  Future<void> createProfile({
    required String name,
    required String studentId,
    required String language,
  }) async {
    final resolvedId = studentId.isNotEmpty ? studentId : const Uuid().v4();

    // ── Step 1: Check local Hive cache ──────────────────────────────
    final existing = _loadFromHive();
    if (existing != null && existing.id == resolvedId) {
      // Same user — update name/language but keep all progress
      state = existing.copyWith(name: name, language: language);
      await _persist();
      debugPrint('✅ Profile restored from Hive (xp=${state.xp})');

      // Sync updated name/language to Firestore
      _syncNameLanguage(resolvedId, name, language);
      return;
    }

    // ── Step 2: Try Firestore for existing cloud progress ────────────
    try {
      final firestore = FirestoreRepository();
      final cloudData = await firestore.fetchProfileById(resolvedId);

      if (cloudData != null && cloudData.isNotEmpty) {
        // Cloud profile found — restore it locally
        final cloudProfile = StudentProfile(
          id: resolvedId,
          name: (cloudData['name'] as String?)?.isNotEmpty == true
              ? cloudData['name'] as String
              : name,
          groupId: cloudData['groupId'] as String? ?? 'group_village_01',
          xp: (cloudData['xp'] as num?)?.toInt() ?? 0,
          streak: (cloudData['streak'] as num?)?.toInt() ?? 0,
          badges: List<String>.from(cloudData['badges'] as List? ?? []),
          language: language, // use whatever user selected at login
        );
        state = cloudProfile;
        await _persist();
        debugPrint('✅ Profile restored from Firestore (xp=${state.xp})');

        // Update language/name in Firestore too
        _syncNameLanguage(resolvedId, name, language);
        return;
      }
    } catch (e) {
      debugPrint('⚠️ Could not fetch profile from Firestore: $e');
    }

    // ── Step 3: Brand new user — create fresh ────────────────────────
    state = StudentProfile(
      id: resolvedId,
      name: name,
      groupId: 'group_village_01',
      xp: 0,
      streak: 0,
      badges: const [],
      language: language,
    );
    await _persist();
    debugPrint('✅ New profile created for $resolvedId');

    // Push full profile to Firestore for new user
    try {
      final firestore = FirestoreRepository();
      await firestore.upsertProfile(
        studentId: resolvedId,
        data: state.toJson(),
      );
    } catch (_) {
      // Will sync when online
    }
  }

  /// Sync only name and language to Firestore without overwriting XP.
  void _syncNameLanguage(String studentId, String name, String language) {
    FirestoreRepository().upsertProfile(
      studentId: studentId,
      data: {'name': name, 'language': language},
    ).catchError((_) {});
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

  void updateName(String name) {
    state = state.copyWith(name: name.trim());
    _persist();
  }

  /// Clears the local profile from Hive on sign out.
  /// Note: Firestore data is kept — it will be restored on next login.
  Future<void> clearProfile() async {
    final box = Hive.box<String>(AppConstants.hiveUserBox);
    await box.delete('profile');
    state = _defaultProfile();
  }
}
