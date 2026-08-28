/// Local model representing a student's profile and gamification state.
class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.name,
    required this.groupId,
    this.imageUrl,
    this.xp = 0,
    this.streak = 0,
    this.badges = const [],
    this.language = 'en',
  });

  final String id;
  final String name;
  final String groupId;
  final String? imageUrl;
  final int xp;
  final int streak;
  final List<String> badges; // badge IDs earned
  final String language;

  StudentProfile copyWith({
    String? id,
    String? name,
    String? groupId,
    String? imageUrl,
    int? xp,
    int? streak,
    List<String>? badges,
    String? language,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      imageUrl: imageUrl ?? this.imageUrl,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      badges: badges ?? this.badges,
      language: language ?? this.language,
    );
  }

  /// Level derived from XP: every 500 XP = 1 level.
  int get level => (xp / 500).floor() + 1;

  /// XP progress within the current level (0.0 – 1.0).
  double get levelProgress => (xp % 500) / 500.0;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      groupId: json['groupId'] as String,
      imageUrl: json['imageUrl'] as String?,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      badges: List<String>.from(json['badges'] as List? ?? []),
      language: json['language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'groupId': groupId,
        'imageUrl': imageUrl,
        'xp': xp,
        'streak': streak,
        'badges': badges,
        'language': language,
      };

  /// Mock profile for UI development.
  static StudentProfile get mock => const StudentProfile(
        id: 'student_001',
        name: 'Priya Sharma',
        groupId: 'group_village_01',
        xp: 1240,
        streak: 7,
        badges: ['first_lesson', 'streak_3', 'quiz_master'],
        language: 'en',
      );
}
