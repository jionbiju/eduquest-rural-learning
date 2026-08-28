import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/sync_action.dart';
import '../data/repositories/firestore_repository.dart';
import '../data/repositories/sync_queue_repository.dart';

// ── Connectivity ──────────────────────────────────────────────────────────────

/// Emits true when the device is online, false when offline.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
});

// ── Repositories ──────────────────────────────────────────────────────────────

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository();
});

final firestoreRepositoryProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository();
});

// ── Pending count ─────────────────────────────────────────────────────────────

final pendingSyncCountProvider = StateProvider<int>((ref) => 0);

// ── Sync service ──────────────────────────────────────────────────────────────

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

class SyncService {
  SyncService(this._ref) {
    _init();
  }

  final Ref _ref;

  void _init() {
    _ref.listen<AsyncValue<bool>>(connectivityProvider, (prev, next) {
      next.whenData((isOnline) {
        if (isOnline) {
          debugPrint('🔄 Connectivity restored — flushing sync queue');
          flushQueue();
        }
      });
    });
  }

  /// Adds an action to the local Hive queue.
  Future<void> enqueue(SyncAction action) async {
    final repo = _ref.read(syncQueueRepositoryProvider);
    await repo.enqueue(action);
    _ref.read(pendingSyncCountProvider.notifier).state = repo.pendingCount;
    debugPrint('📥 Queued sync action: ${action.type.name}');
  }

  /// Flushes all pending actions to Firestore in order.
  /// Successfully synced actions are removed from the queue.
  /// Failed actions increment retry count and stay in queue.
  Future<void> flushQueue() async {
    final queue = _ref.read(syncQueueRepositoryProvider);
    final firestore = _ref.read(firestoreRepositoryProvider);
    final pending = queue.getPending();

    if (pending.isEmpty) {
      debugPrint('✅ Sync queue empty — nothing to flush');
      return;
    }

    debugPrint('🚀 Flushing ${pending.length} sync actions...');
    int successCount = 0;

    for (final action in pending) {
      // Skip actions that have failed too many times.
      if (action.retryCount >= 5) {
        debugPrint('⛔ Dropping action ${action.id} after 5 retries');
        await queue.remove(action.id);
        continue;
      }

      try {
        await firestore.pushSyncAction(action);
        await queue.remove(action.id);
        successCount++;
      } catch (e) {
        await queue.incrementRetry(action.id);
        debugPrint('❌ Sync failed for ${action.id}: $e');
      }
    }

    _ref.read(pendingSyncCountProvider.notifier).state = queue.pendingCount;
    debugPrint('✅ Sync complete: $successCount/${pending.length} actions pushed');
  }
}
