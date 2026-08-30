import 'package:flutter/foundation.dart';

import '../../../../core/services/firestore_service.dart';
import '../models/student_progress.dart';
import '../models/teacher_lesson.dart';

/// Repository for teacher content operations
class TeacherContentRepository {
  final FirestoreService _firestore;

  TeacherContentRepository({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService();

  // ── LESSON CRUD ────────────────────────────────────────────────────

  /// Save a new lesson (draft or published)
  Future<String> saveLesson(TeacherLesson lesson) async {
    try {
      debugPrint('💾 Saving lesson: ${lesson.topicId}');
      final lessonData = lesson.toJson();
      lessonData['createdAt'] = DateTime.now().toIso8601String();
      lessonData['updatedAt'] = DateTime.now().toIso8601String();
      
      final docId = await _firestore.saveLesson(lessonData);
      debugPrint('✅ Lesson saved with ID: $docId');
      return docId;
    } catch (e) {
      debugPrint('❌ Failed to save lesson: $e');
      rethrow;
    }
  }

  /// Update an existing lesson
  Future<void> updateLesson(String lessonId, Map<String, dynamic> updates) async {
    try {
      debugPrint('🔄 Updating lesson: $lessonId');
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.updateLesson(lessonId, updates);
      debugPrint('✅ Lesson updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to update lesson: $e');
      rethrow;
    }
  }

  /// Publish a draft lesson
  Future<void> publishLesson(String lessonId) async {
    await updateLesson(lessonId, {'status': 'published'});
  }

  /// Unpublish a lesson (back to draft)
  Future<void> unpublishLesson(String lessonId) async {
    await updateLesson(lessonId, {'status': 'draft'});
  }

  /// Delete a lesson
  Future<void> deleteLesson(String lessonId) async {
    try {
      debugPrint('🗑️ Deleting lesson: $lessonId');
      await _firestore.deleteLesson(lessonId);
      debugPrint('✅ Lesson deleted successfully');
    } catch (e) {
      debugPrint('❌ Failed to delete lesson: $e');
      rethrow;
    }
  }

  /// Fetch all lessons created by a teacher
  Future<List<TeacherLesson>> getTeacherLessons(String teacherUid) async {
    try {
      debugPrint('📚 Fetching lessons for teacher: $teacherUid');
      final lessons = await _firestore.getTeacherLessons(teacherUid);
      return lessons.map((json) => TeacherLesson.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch teacher lessons: $e');
      return [];
    }
  }

  /// Fetch published lessons for a group (student side)
  Future<List<TeacherLesson>> getLessonsForGroup(String groupId) async {
    try {
      debugPrint('📚 Fetching published lessons for group: $groupId');
      final lessons = await _firestore.getLessonsForGroup(groupId);
      return lessons.map((json) => TeacherLesson.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch group lessons: $e');
      return [];
    }
  }

  // ── STUDENT PROGRESS ───────────────────────────────────────────────

  /// Fetch all students in a teacher's group
  Future<List<StudentProgressData>> getGroupStudents(String groupId) async {
    try {
      debugPrint('👥 Fetching students in group: $groupId');
      final students = await _firestore.getStudentsInGroup(groupId);
      
      // Fetch progress data for each student
      final progressDataList = <StudentProgressData>[];
      for (final student in students) {
        final uid = student['uid'] as String;
        final progress = await _firestore.getStudentProgress(uid);
        
        // Merge user data with progress data
        final merged = {...student};
        if (progress != null) {
          merged.addAll(progress);
        }
        
        progressDataList.add(StudentProgressData.fromJson(merged));
      }
      
      debugPrint('✅ Found ${progressDataList.length} students with progress');
      return progressDataList;
    } catch (e) {
      debugPrint('❌ Failed to fetch group students: $e');
      return [];
    }
  }

  /// Fetch detailed progress for a single student
  Future<StudentProgressData?> getStudentDetail(String studentUid) async {
    try {
      debugPrint('📊 Fetching detail for student: $studentUid');
      
      // Fetch user profile
      final userProfile = await _firestore.getUserProfile(studentUid);
      if (userProfile == null) return null;
      
      // Fetch progress data
      final progress = await _firestore.getStudentProgress(studentUid);
      
      final merged = userProfile.toJson();
      if (progress != null) {
        merged.addAll(progress);
      }
      
      return StudentProgressData.fromJson(merged);
    } catch (e) {
      debugPrint('❌ Failed to fetch student detail: $e');
      return null;
    }
  }

  /// Compute class analytics
  Future<ClassAnalytics> getClassAnalytics(String groupId) async {
    final students = await getGroupStudents(groupId);
    return ClassAnalytics.fromStudents(students);
  }

  // ── STREAMING (REAL-TIME) ──────────────────────────────────────────

  /// Stream lessons for a group (real-time updates)
  Stream<List<TeacherLesson>> streamGroupLessons(String groupId) {
    return _firestore.streamLessonsForGroup(groupId).map(
          (lessons) =>
              lessons.map((json) => TeacherLesson.fromJson(json)).toList(),
        );
  }

  /// Stream students in a group (real-time updates)
  Stream<List<StudentProgressData>> streamGroupStudents(String groupId) {
    return _firestore.streamStudentsInGroup(groupId).asyncMap((students) async {
      final progressDataList = <StudentProgressData>[];
      for (final student in students) {
        final uid = student['uid'] as String;
        final progress = await _firestore.getStudentProgress(uid);
        
        final merged = {...student};
        if (progress != null) {
          merged.addAll(progress);
        }
        
        progressDataList.add(StudentProgressData.fromJson(merged));
      }
      return progressDataList;
    });
  }
}
