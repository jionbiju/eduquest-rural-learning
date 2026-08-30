import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/data/models/auth_user.dart';

/// Service for Firestore operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── USER PROFILES ──────────────────────────────────────────────────────

  /// Save user profile to Firestore after signup
  Future<void> saveUserProfile(AuthUser user) async {
    try {
      debugPrint('💾 Saving user profile to Firestore: ${user.uid}');
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
      debugPrint('✅ User profile saved successfully');
    } catch (e) {
      debugPrint('❌ Failed to save user profile: $e');
      rethrow;
    }
  }

  /// Fetch user profile from Firestore
  Future<AuthUser?> getUserProfile(String uid) async {
    try {
      debugPrint('📥 Fetching user profile from Firestore: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (!doc.exists) {
        debugPrint('⚠️ User profile not found');
        return null;
      }

      debugPrint('✅ User profile fetched successfully');
      return AuthUser.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('❌ Failed to fetch user profile: $e');
      rethrow;
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      debugPrint('🔄 Updating user profile in Firestore: $uid');
      await _firestore.collection('users').doc(uid).update(updates);
      debugPrint('✅ User profile updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to update user profile: $e');
      rethrow;
    }
  }

  // ── LESSONS ────────────────────────────────────────────────────────────

  /// Fetch published lessons for a specific group
  Future<List<Map<String, dynamic>>> getLessonsForGroup(String groupId) async {
    try {
      debugPrint('📚 Fetching lessons for group: $groupId');
      final querySnapshot = await _firestore
          .collection('lessons')
          .where('groupId', isEqualTo: groupId)
          .where('status', isEqualTo: 'published')
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('✅ Found ${querySnapshot.docs.length} lessons');
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch lessons: $e');
      return [];
    }
  }

  /// Save a new lesson (teacher-authored)
  Future<String> saveLesson(Map<String, dynamic> lessonData) async {
    try {
      debugPrint('💾 Saving lesson to Firestore');
      final docRef = await _firestore.collection('lessons').add(lessonData);
      debugPrint('✅ Lesson saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Failed to save lesson: $e');
      rethrow;
    }
  }

  /// Update an existing lesson
  Future<void> updateLesson(String lessonId, Map<String, dynamic> updates) async {
    try {
      debugPrint('🔄 Updating lesson: $lessonId');
      await _firestore.collection('lessons').doc(lessonId).update(updates);
      debugPrint('✅ Lesson updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to update lesson: $e');
      rethrow;
    }
  }

  /// Delete a lesson
  Future<void> deleteLesson(String lessonId) async {
    try {
      debugPrint('🗑️ Deleting lesson: $lessonId');
      await _firestore.collection('lessons').doc(lessonId).delete();
      debugPrint('✅ Lesson deleted successfully');
    } catch (e) {
      debugPrint('❌ Failed to delete lesson: $e');
      rethrow;
    }
  }

  /// Fetch all lessons created by a teacher (including drafts)
  Future<List<Map<String, dynamic>>> getTeacherLessons(String teacherUid) async {
    try {
      debugPrint('📚 Fetching lessons for teacher: $teacherUid');
      final querySnapshot = await _firestore
          .collection('lessons')
          .where('authorUid', isEqualTo: teacherUid)
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('✅ Found ${querySnapshot.docs.length} lessons');
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch teacher lessons: $e');
      return [];
    }
  }

  // ── STUDENT PROGRESS ───────────────────────────────────────────────────

  /// Fetch all students in a group
  Future<List<Map<String, dynamic>>> getStudentsInGroup(String groupId) async {
    try {
      debugPrint('👥 Fetching students in group: $groupId');
      final querySnapshot = await _firestore
          .collection('users')
          .where('groupId', isEqualTo: groupId)
          .where('role', isEqualTo: 'student')
          .get();

      debugPrint('✅ Found ${querySnapshot.docs.length} students');
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch students: $e');
      return [];
    }
  }

  /// Fetch student progress data
  Future<Map<String, dynamic>?> getStudentProgress(String studentUid) async {
    try {
      debugPrint('📊 Fetching progress for student: $studentUid');
      final doc = await _firestore.collection('student_progress').doc(studentUid).get();
      
      if (!doc.exists) {
        debugPrint('⚠️ No progress data found');
        return null;
      }

      debugPrint('✅ Progress data fetched');
      return doc.data();
    } catch (e) {
      debugPrint('❌ Failed to fetch student progress: $e');
      return null;
    }
  }

  /// Stream lessons for a group (real-time updates)
  Stream<List<Map<String, dynamic>>> streamLessonsForGroup(String groupId) {
    return _firestore
        .collection('lessons')
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Stream students in a group (real-time updates)
  Stream<List<Map<String, dynamic>>> streamStudentsInGroup(String groupId) {
    return _firestore
        .collection('users')
        .where('groupId', isEqualTo: groupId)
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
