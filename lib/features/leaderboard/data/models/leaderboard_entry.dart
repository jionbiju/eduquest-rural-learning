/// A single student entry on the class/village leaderboard.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.studentId,
    required this.name,
    required this.xp,
    required this.rank,
    this.imageUrl,
    this.streak = 0,
    this.badges = const [],
  });

  final String studentId;
  final String name;
  final int xp;
  final int rank;
  final String? imageUrl;
  final int streak;
  final List<String> badges;

  int get level => (xp / 500).floor() + 1;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      studentId: json['studentId'] as String,
      name: json['name'] as String,
      xp: (json['xp'] as num).toInt(),
      rank: (json['rank'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      badges: List<String>.from(json['badges'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'name': name,
        'xp': xp,
        'rank': rank,
        'imageUrl': imageUrl,
        'streak': streak,
        'badges': badges,
      };

  /// Mock leaderboard for UI development.
  static List<LeaderboardEntry> get mockList => [
        const LeaderboardEntry(
          studentId: 'student_001',
          name: 'Priya Sharma',
          xp: 1240,
          rank: 1,
          streak: 7,
          badges: ['first_lesson', 'streak_3', 'quiz_master'],
        ),
        const LeaderboardEntry(
          studentId: 'student_002',
          name: 'Ravi Kumar',
          xp: 1100,
          rank: 2,
          streak: 5,
          badges: ['first_lesson', 'streak_3'],
        ),
        const LeaderboardEntry(
          studentId: 'student_003',
          name: 'Anita Patel',
          xp: 980,
          rank: 3,
          streak: 4,
          badges: ['first_lesson'],
        ),
        const LeaderboardEntry(
          studentId: 'student_004',
          name: 'Suresh Yadav',
          xp: 860,
          rank: 4,
          streak: 3,
          badges: ['first_lesson'],
        ),
        const LeaderboardEntry(
          studentId: 'student_005',
          name: 'Meena Singh',
          xp: 720,
          rank: 5,
          streak: 2,
          badges: [],
        ),
        const LeaderboardEntry(
          studentId: 'student_006',
          name: 'Arjun Reddy',
          xp: 640,
          rank: 6,
          streak: 1,
          badges: [],
        ),
        const LeaderboardEntry(
          studentId: 'student_007',
          name: 'Kavya Nair',
          xp: 520,
          rank: 7,
          streak: 0,
          badges: [],
        ),
      ];
}
