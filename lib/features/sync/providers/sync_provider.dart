import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/sync_action.dart';
import '../data/repositories/sync_queue_repository.dart';

// ── Connectivity state ────────────────────────────────────────────────────────

/// Emits true when the device is online, false when offline.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
});

// ── Sync queue repository ─────────────────────────────────────────────────────

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository();
});

// ── Pending count ─────────────────────────────────────────────────────────────

/// Exposes how many actions are waiting to be synced.
final pendingSyncCountProvider = StateProvider<int>((ref) => 0);

// ── Sync service ──────────────────────────────────────────────────────────────

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

/// Listens for connectivity and flushes the pending queue to Firestore.
class SyncService {
  SyncService(this._ref) {
    _init();
  }

  final Ref _ref;

  void _init() {
    // Whenever connectivity changes to online, trigger a sync.
    _ref.listen<AsyncValue<bool>>(connectivityProvider, (prev, next) {
      next.whenData((isOnline) {
        if (isOnline) flushQueue();
      });
    });
  }

  /// Adds an action to the local queue.
  Future<void> enqueue(SyncAction action) async {
    final repo = _ref.read(syncQueueRepositoryProvider);
    await repo.enqueue(action);
    _ref.read(pendingSyncCountProvider.notifier).state = repo.pendingCount;
  }

  /// Pushes all pending actions to Firestore in batches.
  /// Clears successfully synced actions. Retries on failure.
  Future<void> flushQueue() async {
    final repo = _ref.read(syncQueueRepositoryProvider);
    final pending = repo.getPending();
    if (pending.isEmpty) return;

    // TODO: Replace with real Firestore batch writes when Firebase is configured.
    // For now this simulates a successful sync.
    for (final action in pending) {
      try {
        await _simulateFirestoreWrite(action);
        await repo.remove(action.id);
      } catch (_) {
        await repo.incrementRetry(action.id);
      }
    }

    _ref.read(pendingSyncCountProvider.notifier).state = repo.pendingCount;
  }

  /// Placeholder for real Firestore write — swap this out when Firebase is live.
  Future<void> _simulateFirestoreWrite(SyncAction action) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Firestore write will go here:
    // await FirebaseFirestore.instance
    //   .collection('students')
    //   .doc(action.studentId)
    //   .collection('progress')
    //   .doc(action.id)
    //   .set(action.payload);
  }
}
