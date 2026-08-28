import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/leaderboard_entry.dart';

/// Provides leaderboard entries scoped to the student's group.
/// Uses mock data until Firestore is wired in.
final leaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  // Simulate a small network delay.
  await Future.delayed(const Duration(milliseconds: 600));
  return LeaderboardEntry.mockList;
});
