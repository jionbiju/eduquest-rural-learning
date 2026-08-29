import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase_service.dart';
import '../../../features/home/providers/home_provider.dart';
import '../../../features/sync/data/repositories/firestore_repository.dart';
import '../data/models/leaderboard_entry.dart';

/// Provides the [FirestoreRepository] for leaderboard queries.
final _firestoreRepoProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository();
});

/// Real-time leaderboard stream from Firestore merged with local profile state.
/// Ensures real-time responsiveness when students earn XP.
final leaderboardProvider =
    StreamProvider<List<LeaderboardEntry>>((ref) {
  final repo = ref.watch(_firestoreRepoProvider);
  final profile = ref.watch(studentProfileProvider);

  // If Firebase is not initialised, fall back to local student profile.
  if (!FirebaseService.isInitialised) {
    debugPrint('⚠️ Firebase not ready — displaying local student on leaderboard');
    final localEntry = LeaderboardEntry(
      studentId: profile.id,
      name: profile.name,
      xp: profile.xp,
      rank: 1,
      streak: profile.streak,
      badges: profile.badges,
      imageUrl: profile.imageUrl,
    );
    return Stream.value([localEntry]);
  }

  // Stream real-time updates from Firestore.
  return repo.leaderboardStream().map((rawList) {
    final entries = <LeaderboardEntry>[];
    bool localUserFound = false;

    for (final data in rawList) {
      final sId = data['studentId'] as String? ?? '';
      int xp = (data['xp'] as num?)?.toInt() ?? 0;
      String name = data['name'] as String? ??
          data['displayName'] as String? ??
          'Student';
      int streak = (data['streak'] as num?)?.toInt() ?? 0;
      List<String> badges = List<String>.from(data['badges'] as List? ?? []);
      String? imageUrl = data['imageUrl'] as String? ?? data['photoUrl'] as String?;

      if (sId == profile.id) {
        localUserFound = true;
        // Use the higher XP between local Hive state and Firestore
        if (profile.xp > xp) {
          xp = profile.xp;
        }
        name = profile.name;
        streak = profile.streak;
        badges = profile.badges;
      }

      entries.add(LeaderboardEntry(
        studentId: sId,
        name: name,
        xp: xp,
        rank: 0,
        streak: streak,
        badges: badges,
        imageUrl: imageUrl,
      ));
    }

    if (!localUserFound) {
      // Ensure the logged-in student always appears on the leaderboard
      entries.add(LeaderboardEntry(
        studentId: profile.id,
        name: profile.name,
        xp: profile.xp,
        rank: 0,
        streak: profile.streak,
        badges: profile.badges,
        imageUrl: profile.imageUrl,
      ));
    }

    // Sort descending by XP
    entries.sort((a, b) => b.xp.compareTo(a.xp));

    // Assign sorted 1-indexed ranks
    final ranked = List.generate(entries.length, (i) {
      final e = entries[i];
      return LeaderboardEntry(
        studentId: e.studentId,
        name: e.name,
        xp: e.xp,
        rank: i + 1,
        streak: e.streak,
        badges: e.badges,
        imageUrl: e.imageUrl,
      );
    });

    debugPrint('✅ Leaderboard: ${ranked.length} students loaded (Current User: ${profile.name} - ${profile.xp} XP)');
    return ranked;
  }).handleError((e) {
    debugPrint('❌ Leaderboard stream error: $e');
    return [
      LeaderboardEntry(
        studentId: profile.id,
        name: profile.name,
        xp: profile.xp,
        rank: 1,
        streak: profile.streak,
        badges: profile.badges,
        imageUrl: profile.imageUrl,
      ),
    ];
  });
});

/// One-time fetch of leaderboard (used for pull-to-refresh).
final leaderboardFetchProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  final repo = ref.watch(_firestoreRepoProvider);
  final profile = ref.watch(studentProfileProvider);

  if (!FirebaseService.isInitialised) {
    return [
      LeaderboardEntry(
        studentId: profile.id,
        name: profile.name,
        xp: profile.xp,
        rank: 1,
        streak: profile.streak,
        badges: profile.badges,
        imageUrl: profile.imageUrl,
      ),
    ];
  }

  final rawList = await repo.fetchLeaderboard();
  final entries = <LeaderboardEntry>[];
  bool localUserFound = false;

  for (final data in rawList) {
    final sId = data['studentId'] as String? ?? '';
    int xp = (data['xp'] as num?)?.toInt() ?? 0;
    String name = data['name'] as String? ??
        data['displayName'] as String? ??
        'Student';
    int streak = (data['streak'] as num?)?.toInt() ?? 0;
    List<String> badges = List<String>.from(data['badges'] as List? ?? []);
    String? imageUrl = data['imageUrl'] as String? ?? data['photoUrl'] as String?;

    if (sId == profile.id) {
      localUserFound = true;
      if (profile.xp > xp) xp = profile.xp;
      name = profile.name;
    }

    entries.add(LeaderboardEntry(
      studentId: sId,
      name: name,
      xp: xp,
      rank: 0,
      streak: streak,
      badges: badges,
      imageUrl: imageUrl,
    ));
  }

  if (!localUserFound) {
    entries.add(LeaderboardEntry(
      studentId: profile.id,
      name: profile.name,
      xp: profile.xp,
      rank: 0,
      streak: profile.streak,
      badges: profile.badges,
      imageUrl: profile.imageUrl,
    ));
  }

  entries.sort((a, b) => b.xp.compareTo(a.xp));
  return List.generate(entries.length, (i) {
    final e = entries[i];
    return LeaderboardEntry(
      studentId: e.studentId,
      name: e.name,
      xp: e.xp,
      rank: i + 1,
      streak: e.streak,
      badges: e.badges,
      imageUrl: e.imageUrl,
    );
  });
});
