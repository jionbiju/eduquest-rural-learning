/// Types of actions that get queued for sync to Firestore.
enum SyncActionType {
  lessonCompleted,
  quizAnswered,
  xpEarned,
  streakUpdated,
  badgeEarned,
}

/// A single pending action waiting to be synced to Firestore.
class SyncAction {
  SyncAction({
    required this.id,
    required this.type,
    required this.studentId,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });

  final String id;
  final SyncActionType type;
  final String studentId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  int retryCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'studentId': studentId,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory SyncAction.fromJson(Map<String, dynamic> json) {
    return SyncAction(
      id: json['id'] as String,
      type: SyncActionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => SyncActionType.xpEarned,
      ),
      studentId: json['studentId'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Creates a lesson completed action.
  factory SyncAction.lessonCompleted({
    required String id,
    required String studentId,
    required String lessonId,
    required int xpEarned,
  }) {
    return SyncAction(
      id: id,
      type: SyncActionType.lessonCompleted,
      studentId: studentId,
      payload: {'lessonId': lessonId, 'xpEarned': xpEarned},
      createdAt: DateTime.now(),
    );
  }

  /// Creates a quiz answered action.
  factory SyncAction.quizAnswered({
    required String id,
    required String studentId,
    required String questionId,
    required bool isCorrect,
    required int xpEarned,
  }) {
    return SyncAction(
      id: id,
      type: SyncActionType.quizAnswered,
      studentId: studentId,
      payload: {
        'questionId': questionId,
        'isCorrect': isCorrect,
        'xpEarned': xpEarned,
      },
      createdAt: DateTime.now(),
    );
  }
}
