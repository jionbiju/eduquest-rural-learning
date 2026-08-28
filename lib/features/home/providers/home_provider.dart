import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/student_profile.dart';

/// Provides the current student profile.
/// Uses mock data until Hive + Firebase are wired in.
final studentProfileProvider =
    StateNotifierProvider<StudentProfileNotifier, StudentProfile>(
  (ref) => StudentProfileNotifier(),
);

class StudentProfileNotifier extends StateNotifier<StudentProfile> {
  StudentProfileNotifier() : super(StudentProfile.mock);

  void addXp(int amount) {
    state = state.copyWith(xp: state.xp + amount);
  }

  void incrementStreak() {
    state = state.copyWith(streak: state.streak + 1);
  }

  void earnBadge(String badgeId) {
    if (!state.badges.contains(badgeId)) {
      state = state.copyWith(badges: [...state.badges, badgeId]);
    }
  }

  void updateLanguage(String lang) {
    state = state.copyWith(language: lang);
  }
}
