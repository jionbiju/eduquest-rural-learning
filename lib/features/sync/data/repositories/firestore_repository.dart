import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/sync_action.dart';

/// Handles all Firestore read/write operations.
/// Every method checks if Firebase is initialised first —
/// if not, operations are silently skipped (offline-only mode).
class FirestoreRepository {
  FirebaseFirestore? get _db {
    if (!FirebaseService.isInitialised) return null;
    return FirebaseFirestore.instance;
  }

  // ── Student profile ─────────────────────────────────────────────────────

  /// Writes or updates the student's profile document.
  Future<void> upsertProfile({
    required String studentId,
    required Map<String, dynamic> data,
  }) async {
    final db = _db;
    if (db == null) return;
    try {
      await db
          .collection(AppConstants.fsStudents)
          .doc(studentId)
          .collection(AppConstants.fsProfile)
          .doc('data')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore upsertProfile error: $e');
    }
  }

  /// Fetches a single student's profile data by UID.
  /// Returns null if not found or Firebase unavailable.
  Future<Map<String, dynamic>?> fetchProfileById(String studentId) async {
    final db = _db;
    if (db == null) return null;
    try {
      final snap = await db
          .collection(AppConstants.fsStudents)
          .doc(studentId)
          .collection(AppConstants.fsProfile)
          .doc('data')
          .get();
      if (snap.exists && snap.data() != null) {
        debugPrint('✅ Fetched profile from Firestore for $studentId');
        return snap.data();
      }
      return null;
    } catch (e) {
      debugPrint('Firestore fetchProfileById error: $e');
      return null;
    }
  }

  // ── Progress ─────────────────────────────────────────────────────────────

  /// Writes a lesson completion record.
  Future<void> writeLessonProgress({
    required String studentId,
    required String lessonId,
    required Map<String, dynamic> data,
  }) async {
    final db = _db;
    if (db == null) return;
    try {
      await db
          .collection(AppConstants.fsStudents)
          .doc(studentId)
          .collection(AppConstants.fsProgress)
          .doc(lessonId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore writeLessonProgress error: $e');
    }
  }

  // ── Leaderboard ───────────────────────────────────────────────────────────

  /// Reads all student profiles using a collectionGroup query on 'profile'.
  /// This directly queries all `students/{uid}/profile/data` documents.
  /// Falls back to empty list if Firebase is unavailable.
  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    final db = _db;
    if (db == null) {
      debugPrint('⚠️ Firestore not available — leaderboard offline');
      return [];
    }
    try {
      debugPrint('📊 Fetching leaderboard via collectionGroup...');

      // collectionGroup('profile') queries ALL /profile subcollections.
      // No where filter needed — we just grab all profile docs.
      final snap = await db
          .collectionGroup(AppConstants.fsProfile)
          .get();

      final results = <Map<String, dynamic>>[];

      for (final doc in snap.docs) {
        final data = doc.data();
        // Skip empty docs or docs without a name (not a real profile)
        if (data.isEmpty || !data.containsKey('name')) continue;

        // Extract studentId from path: students/{uid}/profile/data
        final pathSegments = doc.reference.path.split('/');
        final studentId = pathSegments.length >= 2 ? pathSegments[1] : doc.id;

        results.add({
          ...data,
          'studentId': studentId,
        });
      }

      // Sort by XP descending
      results.sort((a, b) {
        final xpA = (a['xp'] as num?)?.toInt() ?? 0;
        final xpB = (b['xp'] as num?)?.toInt() ?? 0;
        return xpB.compareTo(xpA);
      });

      debugPrint('✅ Leaderboard fetched: ${results.length} students');
      return results;
    } catch (e) {
      debugPrint('Firestore fetchLeaderboard error: $e');
      return [];
    }
  }

  /// Real-time stream of all student profiles sorted by XP.
  /// Uses collectionGroup to efficiently stream all profile subcollections.
  Stream<List<Map<String, dynamic>>> leaderboardStream() {
    final db = _db;
    if (db == null) return const Stream.empty();

    return db
        .collectionGroup(AppConstants.fsProfile)
        .snapshots()
        .map((snap) {
      final results = <Map<String, dynamic>>[];

      for (final doc in snap.docs) {
        final data = doc.data();
        // Skip empty docs or docs without a name (not a real profile)
        if (data.isEmpty || !data.containsKey('name')) continue;

        // Extract studentId from path: students/{uid}/profile/data
        final pathSegments = doc.reference.path.split('/');
        final studentId = pathSegments.length >= 2 ? pathSegments[1] : doc.id;

        results.add({
          ...data,
          'studentId': studentId,
        });
      }

      // Sort by XP descending
      results.sort((a, b) {
        final xpA = (a['xp'] as num?)?.toInt() ?? 0;
        final xpB = (b['xp'] as num?)?.toInt() ?? 0;
        return xpB.compareTo(xpA);
      });

      debugPrint('📊 Leaderboard stream update: ${results.length} students');
      return results;
    });
  }

  /// Legacy: kept for compatibility.
  Future<List<Map<String, dynamic>>> getLeaderboard(String groupId) async {
    return fetchLeaderboard();
  }

  // ── Sync batch ────────────────────────────────────────────────────────────

  /// Pushes a single [SyncAction] to Firestore.
  Future<void> pushSyncAction(SyncAction action) async {
    final db = _db;
    if (db == null) return;
    try {
      switch (action.type) {
        case SyncActionType.lessonCompleted:
          await writeLessonProgress(
            studentId: action.studentId,
            lessonId: action.payload['lessonId'] as String,
            data: {
              'completed': true,
              'xpEarned': action.payload['xpEarned'],
              'completedAt': FieldValue.serverTimestamp(),
            },
          );

        case SyncActionType.quizAnswered:
          await db
              .collection(AppConstants.fsStudents)
              .doc(action.studentId)
              .collection('quiz_answers')
              .doc(action.id)
              .set({
            ...action.payload,
            'answeredAt': FieldValue.serverTimestamp(),
          });

        case SyncActionType.xpEarned:
          await upsertProfile(
            studentId: action.studentId,
            data: {
              'xp': FieldValue.increment(
                  action.payload['amount'] as int),
            },
          );

        case SyncActionType.streakUpdated:
          await upsertProfile(
            studentId: action.studentId,
            data: {'streak': action.payload['streak']},
          );

        case SyncActionType.badgeEarned:
          await upsertProfile(
            studentId: action.studentId,
            data: {
              'badges':
                  FieldValue.arrayUnion([action.payload['badgeId']]),
            },
          );
      }
    } catch (e) {
      debugPrint('Firestore pushSyncAction error: $e');
      rethrow; // Let SyncService handle retry.
    }
  }
}
