import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase_service.dart';
import '../../../features/sync/data/repositories/firestore_repository.dart';
import '../data/models/leaderboard_entry.dart';

/// Provides the [FirestoreRepository] for leaderboard queries.
final _firestoreRepoProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository();
});

/// Real-time leaderboard stream from Firestore.
/// Falls back to mock data if Firebase is unavailable (offline).
final leaderboardProvider =
    StreamProvider<List<LeaderboardEntry>>((ref) {
  final repo = ref.watch(_firestoreRepoProvider);

  // If Firebase is not initialised, fall back to empty list.
  if (!FirebaseService.isInitialised) {
    debugPrint('⚠️ Firebase not ready — leaderboard unavailable offline');
    return Stream.value(<LeaderboardEntry>[]);
  }

  // Stream real-time updates from Firestore.
  return repo.leaderboardStream().map((rawList) {
    if (rawList.isEmpty) {
      // Only show mock when there are truly no real users yet
      debugPrint('ℹ️ No students in Firestore yet');
      return <LeaderboardEntry>[];
    }

    // Convert raw Firestore maps to LeaderboardEntry with computed rank.
    final entries = rawList.asMap().entries.map((e) {
      final index = e.key;
      final data = e.value;
      return LeaderboardEntry(
        studentId: data['studentId'] as String? ?? '',
        name: data['name'] as String? ??
            data['displayName'] as String? ??
            'Student',
        xp: (data['xp'] as num?)?.toInt() ?? 0,
        rank: index + 1, // rank is position in sorted list
        streak: (data['streak'] as num?)?.toInt() ?? 0,
        badges: List<String>.from(data['badges'] as List? ?? []),
        imageUrl: data['imageUrl'] as String? ??
            data['photoUrl'] as String?,
      );
    }).toList();

    debugPrint('✅ Leaderboard: ${entries.length} students loaded');
    return entries;
  }).handleError((e) {
    debugPrint('❌ Leaderboard stream error: $e');
    return <LeaderboardEntry>[];
  });
});

/// One-time fetch of leaderboard (use for pull-to-refresh).
final leaderboardFetchProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  final repo = ref.watch(_firestoreRepoProvider);

  if (!FirebaseService.isInitialised) {
    return LeaderboardEntry.mockList;
  }

  final rawList = await repo.fetchLeaderboard();

  if (rawList.isEmpty) return [];

  return rawList.asMap().entries.map((e) {
    final index = e.key;
    final data = e.value;
    return LeaderboardEntry(
      studentId: data['studentId'] as String? ?? '',
      name: data['name'] as String? ??
          data['displayName'] as String? ??
          'Student',
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      rank: index + 1,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      badges: List<String>.from(data['badges'] as List? ?? []),
      imageUrl: data['imageUrl'] as String? ??
          data['photoUrl'] as String?,
    );
  }).toList();
});
