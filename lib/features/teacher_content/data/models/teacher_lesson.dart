/// Teacher-authored lesson that syncs to Firestore
/// Schema compatible with sample_bundle.json structure
class TeacherLesson {
  const TeacherLesson({
    this.id,
    required this.topicId,
    required this.topicName,
    required this.subjectId,
    required this.difficulty,
    required this.lessonText,
    this.audioUrl,
    this.imageUrl,
    required this.questions,
    required this.groupId,
    required this.authorUid,
    required this.authorName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.completionCount = 0,
    this.averageScore = 0.0,
  });

  /// Firestore document ID (null before saving)
  final String? id;

  /// Topic ID (e.g. "math_addition")
  final String topicId;

  /// Topic name in English and Hindi
  final Map<String, String> topicName;

  /// Subject ID (e.g. "math", "science")
  final String subjectId;

  /// Difficulty tier (1-3)
  final int difficulty;

  /// Lesson text content in English and Hindi
  final Map<String, String> lessonText;

  /// Optional audio file URL from Firebase Storage
  final String? audioUrl;

  /// Optional illustration URL from Firebase Storage
  final String? imageUrl;

  /// Quiz questions
  final List<QuizQuestion> questions;

  /// Group/class ID this lesson belongs to
  final String groupId;

  /// Teacher who authored this lesson
  final String authorUid;

  /// Teacher name for display
  final String authorName;

  /// Status: "draft" or "published"
  final String status;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// How many students completed this lesson
  final int completionCount;

  /// Average quiz score (0-100)
  final double averageScore;

  TeacherLesson copyWith({
    String? id,
    String? topicId,
    Map<String, String>? topicName,
    String? subjectId,
    int? difficulty,
    Map<String, String>? lessonText,
    String? audioUrl,
    String? imageUrl,
    List<QuizQuestion>? questions,
    String? groupId,
    String? authorUid,
    String? authorName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? completionCount,
    double? averageScore,
  }) {
    return TeacherLesson(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      topicName: topicName ?? this.topicName,
      subjectId: subjectId ?? this.subjectId,
      difficulty: difficulty ?? this.difficulty,
      lessonText: lessonText ?? this.lessonText,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      questions: questions ?? this.questions,
      groupId: groupId ?? this.groupId,
      authorUid: authorUid ?? this.authorUid,
      authorName: authorName ?? this.authorName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completionCount: completionCount ?? this.completionCount,
      averageScore: averageScore ?? this.averageScore,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'topicId': topicId,
        'topicName': topicName,
        'subjectId': subjectId,
        'difficulty': difficulty,
        'lessonText': lessonText,
        'audioUrl': audioUrl,
        'imageUrl': imageUrl,
        'questions': questions.map((q) => q.toJson()).toList(),
        'groupId': groupId,
        'authorUid': authorUid,
        'authorName': authorName,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'completionCount': completionCount,
        'averageScore': averageScore,
      };

  factory TeacherLesson.fromJson(Map<String, dynamic> json) {
    return TeacherLesson(
      id: json['id'] as String?,
      topicId: json['topicId'] as String,
      topicName: Map<String, String>.from(json['topicName'] as Map),
      subjectId: json['subjectId'] as String,
      difficulty: (json['difficulty'] as num).toInt(),
      lessonText: Map<String, String>.from(json['lessonText'] as Map),
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      groupId: json['groupId'] as String,
      authorUid: json['authorUid'] as String,
      authorName: json['authorName'] as String,
      status: json['status'] as String? ?? 'draft',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      completionCount: (json['completionCount'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to the format expected by student app (topic structure)
  Map<String, dynamic> toTopicFormat() => {
        'id': topicId,
        'name': topicName,
        'difficulty': difficulty,
        'audioRef': audioUrl,
        'illustrationRef': imageUrl,
        'lessonText': lessonText,
        'questions': questions
            .map((q) => {
                  'id': q.id,
                  'difficulty': difficulty,
                  'text': q.text,
                  'options': q.options,
                  'correctIndex': q.correctIndex,
                  'explanation': q.explanation,
                })
            .toList(),
      };
}

/// Quiz question for a lesson
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  /// Question ID
  final String id;

  /// Question text in English and Hindi
  final Map<String, String> text;

  /// Answer options (4 options)
  final List<String> options;

  /// Index of correct answer (0-3)
  final int correctIndex;

  /// Explanation in English and Hindi
  final Map<String, String> explanation;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      text: Map<String, String>.from(json['text'] as Map),
      options: List<String>.from(json['options'] as List),
      correctIndex: (json['correctIndex'] as num).toInt(),
      explanation: Map<String, String>.from(json['explanation'] as Map),
    );
  }
}

/// Draft lesson (not yet saved to Firestore)
class LessonDraft {
  const LessonDraft({
    this.topicName = const {'en': '', 'hi': ''},
    this.subjectId = 'math',
    this.difficulty = 1,
    this.lessonText = const {'en': '', 'hi': ''},
    this.audioUrl,
    this.imageUrl,
    this.questions = const [],
  });

  final Map<String, String> topicName;
  final String subjectId;
  final int difficulty;
  final Map<String, String> lessonText;
  final String? audioUrl;
  final String? imageUrl;
  final List<QuizQuestion> questions;

  LessonDraft copyWith({
    Map<String, String>? topicName,
    String? subjectId,
    int? difficulty,
    Map<String, String>? lessonText,
    String? audioUrl,
    String? imageUrl,
    List<QuizQuestion>? questions,
  }) {
    return LessonDraft(
      topicName: topicName ?? this.topicName,
      subjectId: subjectId ?? this.subjectId,
      difficulty: difficulty ?? this.difficulty,
      lessonText: lessonText ?? this.lessonText,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      questions: questions ?? this.questions,
    );
  }

  /// Check if lesson is ready to save
  bool get isValid {
    return topicName['en']!.isNotEmpty &&
        lessonText['en']!.isNotEmpty &&
        questions.length >= 3;
  }
}
