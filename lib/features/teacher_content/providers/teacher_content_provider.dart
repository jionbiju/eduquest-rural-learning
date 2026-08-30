import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/student_progress.dart';
import '../data/models/teacher_lesson.dart';
import '../data/repositories/teacher_content_repository.dart';

/// Provides the teacher content repository
final teacherContentRepositoryProvider = Provider<TeacherContentRepository>((ref) {
  return TeacherContentRepository();
});

/// Provides class analytics for a teacher's group
final classAnalyticsProvider = FutureProvider.family<ClassAnalytics, String>(
  (ref, groupId) async {
    final repository = ref.watch(teacherContentRepositoryProvider);
    return repository.getClassAnalytics(groupId);
  },
);

/// Provides list of students in a teacher's group
final groupStudentsProvider = FutureProvider.family<List<StudentProgressData>, String>(
  (ref, groupId) async {
    final repository = ref.watch(teacherContentRepositoryProvider);
    return repository.getGroupStudents(groupId);
  },
);

/// Streams students in a group (real-time)
final groupStudentsStreamProvider = StreamProvider.family<List<StudentProgressData>, String>(
  (ref, groupId) {
    final repository = ref.watch(teacherContentRepositoryProvider);
    return repository.streamGroupStudents(groupId);
  },
);

/// Provides detailed progress for a single student
final studentDetailProvider = FutureProvider.family<StudentProgressData?, String>(
  (ref, studentUid) async {
    final repository = ref.watch(teacherContentRepositoryProvider);
    return repository.getStudentDetail(studentUid);
  },
);

/// Provides all lessons created by a teacher
final teacherLessonsProvider = FutureProvider.family<List<TeacherLesson>, String>(
  (ref, teacherUid) async {
    final repository = ref.watch(teacherContentRepositoryProvider);
    return repository.getTeacherLessons(teacherUid);
  },
);

/// Streams lessons for a group (real-time)
final groupLessonsStreamProvider = StreamProvider.family<List<TeacherLesson>, String>(
  (ref, groupId) {
    final repository = ref.watch(teacherContentRepositoryProvider);
    return repository.streamGroupLessons(groupId);
  },
);

/// State notifier for lesson authoring
final lessonDraftProvider = StateNotifierProvider<LessonDraftNotifier, LessonDraft>(
  (ref) => LessonDraftNotifier(),
);

class LessonDraftNotifier extends StateNotifier<LessonDraft> {
  LessonDraftNotifier() : super(const LessonDraft());

  void reset() {
    state = const LessonDraft();
  }

  void updateTopicName(String en, String hi) {
    state = state.copyWith(topicName: {'en': en, 'hi': hi});
  }

  void updateSubject(String subjectId) {
    state = state.copyWith(subjectId: subjectId);
  }

  void updateDifficulty(int difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  void updateLessonText(String en, String hi) {
    state = state.copyWith(lessonText: {'en': en, 'hi': hi});
  }

  void updateAudioUrl(String? url) {
    state = state.copyWith(audioUrl: url);
  }

  void updateImageUrl(String? url) {
    state = state.copyWith(imageUrl: url);
  }

  void addQuestion(QuizQuestion question) {
    state = state.copyWith(questions: [...state.questions, question]);
  }

  void updateQuestion(int index, QuizQuestion question) {
    final questions = [...state.questions];
    questions[index] = question;
    state = state.copyWith(questions: questions);
  }

  void removeQuestion(int index) {
    final questions = [...state.questions];
    questions.removeAt(index);
    state = state.copyWith(questions: questions);
  }

  /// Convert draft to TeacherLesson
  TeacherLesson toLesson({
    required String authorUid,
    required String authorName,
    required String groupId,
    required String status,
  }) {
    return TeacherLesson(
      topicId: '${state.subjectId}_${DateTime.now().millisecondsSinceEpoch}',
      topicName: state.topicName,
      subjectId: state.subjectId,
      difficulty: state.difficulty,
      lessonText: state.lessonText,
      audioUrl: state.audioUrl,
      imageUrl: state.imageUrl,
      questions: state.questions,
      groupId: groupId,
      authorUid: authorUid,
      authorName: authorName,
      status: status,
      createdAt: DateTime.now(),
    );
  }
}

/// Provider for saving lessons
final saveLessonProvider = Provider<Future<String> Function(TeacherLesson)>((ref) {
  return (lesson) async {
    final repository = ref.read(teacherContentRepositoryProvider);
    return repository.saveLesson(lesson);
  };
});

/// Provider for publishing lessons
final publishLessonProvider = Provider<Future<void> Function(String)>((ref) {
  return (lessonId) async {
    final repository = ref.read(teacherContentRepositoryProvider);
    return repository.publishLesson(lessonId);
  };
});

/// Provider for deleting lessons
final deleteLessonProvider = Provider<Future<void> Function(String)>((ref) {
  return (lessonId) async {
    final repository = ref.read(teacherContentRepositoryProvider);
    return repository.deleteLesson(lessonId);
  };
});
