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

  /// Reads leaderboard entries for a group, ordered by XP descending.
  Future<List<Map<String, dynamic>>> getLeaderboard(String groupId) async {
    final db = _db;
    if (db == null) return [];
    try {
      final snap = await db
          .collection(AppConstants.fsGroups)
          .doc(groupId)
          .collection(AppConstants.fsLeaderboard)
          .orderBy('xp', descending: true)
          .limit(20)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint('Firestore getLeaderboard error: $e');
      return [];
    }
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
