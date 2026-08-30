/// Student progress data for teacher dashboard
class StudentProgressData {
  const StudentProgressData({
    required this.studentUid,
    required this.studentName,
    this.imageUrl,
    required this.groupId,
    required this.xp,
    required this.streak,
    required this.level,
    required this.completedLessons,
    required this.topicAccuracy,
    this.weakestTopic,
    this.lastActive,
  });

  /// Student's Firebase UID
  final String studentUid;

  /// Student's display name
  final String studentName;

  /// Optional profile image URL
  final String? imageUrl;

  /// Group/class ID
  final String groupId;

  /// Total XP earned
  final int xp;

  /// Current streak (days)
  final int streak;

  /// Computed level
  final int level;

  /// List of completed lesson/topic IDs
  final List<String> completedLessons;

  /// Map of topicId -> accuracy percentage (0-100)
  final Map<String, double> topicAccuracy;

  /// Topic with lowest accuracy (if any)
  final TopicScore? weakestTopic;

  /// Last activity timestamp
  final DateTime? lastActive;

  /// Check if student studied today
  bool get studiedToday {
    if (lastActive == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActiveDay = DateTime(
      lastActive!.year,
      lastActive!.month,
      lastActive!.day,
    );
    return lastActiveDay.isAtSameMomentAs(today);
  }

  factory StudentProgressData.fromJson(Map<String, dynamic> json) {
    return StudentProgressData(
      studentUid: json['studentUid'] as String? ?? json['uid'] as String,
      studentName: json['studentName'] as String? ?? json['displayName'] as String,
      imageUrl: json['imageUrl'] as String? ?? json['photoUrl'] as String?,
      groupId: json['groupId'] as String,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? ((json['xp'] as num?)?.toInt() ?? 0) ~/ 500 + 1,
      completedLessons: json['completedLessons'] != null
          ? List<String>.from(json['completedLessons'] as List)
          : [],
      topicAccuracy: json['topicAccuracy'] != null
          ? (json['topicAccuracy'] as Map).map(
              (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
            )
          : {},
      weakestTopic: json['weakestTopic'] != null
          ? TopicScore.fromJson(json['weakestTopic'] as Map<String, dynamic>)
          : null,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'studentUid': studentUid,
        'studentName': studentName,
        'imageUrl': imageUrl,
        'groupId': groupId,
        'xp': xp,
        'streak': streak,
        'level': level,
        'completedLessons': completedLessons,
        'topicAccuracy': topicAccuracy,
        'weakestTopic': weakestTopic?.toJson(),
        'lastActive': lastActive?.toIso8601String(),
      };
}

/// Topic score summary
class TopicScore {
  const TopicScore({
    required this.topicId,
    required this.topicName,
    required this.accuracy,
    required this.attemptsCount,
  });

  final String topicId;
  final String topicName;
  final double accuracy; // 0-100
  final int attemptsCount;

  factory TopicScore.fromJson(Map<String, dynamic> json) {
    return TopicScore(
      topicId: json['topicId'] as String,
      topicName: json['topicName'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      attemptsCount: (json['attemptsCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'topicId': topicId,
        'topicName': topicName,
        'accuracy': accuracy,
        'attemptsCount': attemptsCount,
      };
}

/// Class-level analytics
class ClassAnalytics {
  const ClassAnalytics({
    required this.totalStudents,
    required this.activeToday,
    required this.averageStreak,
    required this.strugglingTopics,
    required this.topPerformers,
  });

  final int totalStudents;
  final int activeToday;
  final double averageStreak;
  final List<StrugglingTopic> strugglingTopics;
  final List<StudentProgressData> topPerformers;

  /// Generate "Class Pulse" summary sentence
  String get classPulse {
    if (totalStudents == 0) return 'No students in this class yet';
    
    final activePercent = (activeToday / totalStudents * 100).round();
    final streakText = averageStreak >= 3 
        ? '${averageStreak.toStringAsFixed(1)}-day average streak 🔥'
        : 'building momentum';
    
    return '$activeToday of $totalStudents students studied today ($activePercent%) • $streakText';
  }

  factory ClassAnalytics.fromStudents(List<StudentProgressData> students) {
    if (students.isEmpty) {
      return const ClassAnalytics(
        totalStudents: 0,
        activeToday: 0,
        averageStreak: 0,
        strugglingTopics: [],
        topPerformers: [],
      );
    }

    final activeToday = students.where((s) => s.studiedToday).length;
    final averageStreak = students.isEmpty
        ? 0.0
        : students.map((s) => s.streak).reduce((a, b) => a + b) / students.length;

    // Find struggling topics (>40% of students score <50%)
    final topicScores = <String, List<double>>{};
    for (final student in students) {
      for (final entry in student.topicAccuracy.entries) {
        topicScores.putIfAbsent(entry.key, () => []).add(entry.value);
      }
    }

    final strugglingTopics = <StrugglingTopic>[];
    for (final entry in topicScores.entries) {
      final scores = entry.value;
      final struggling = scores.where((score) => score < 50).length;
      final strugglePercent = struggling / scores.length;
      
      if (strugglePercent > 0.4 && scores.length >= 3) {
        strugglingTopics.add(StrugglingTopic(
          topicId: entry.key,
          topicName: entry.key, // TODO: resolve to actual name
          strugglingCount: struggling,
          totalAttempts: scores.length,
          averageScore: scores.reduce((a, b) => a + b) / scores.length,
        ));
      }
    }

    // Top 3 performers by XP
    final sorted = [...students]..sort((a, b) => b.xp.compareTo(a.xp));
    final topPerformers = sorted.take(3).toList();

    return ClassAnalytics(
      totalStudents: students.length,
      activeToday: activeToday,
      averageStreak: averageStreak,
      strugglingTopics: strugglingTopics,
      topPerformers: topPerformers,
    );
  }
}

/// Topic that many students struggle with
class StrugglingTopic {
  const StrugglingTopic({
    required this.topicId,
    required this.topicName,
    required this.strugglingCount,
    required this.totalAttempts,
    required this.averageScore,
  });

  final String topicId;
  final String topicName;
  final int strugglingCount;
  final int totalAttempts;
  final double averageScore;

  double get strugglePercentage => strugglingCount / totalAttempts * 100;
}
