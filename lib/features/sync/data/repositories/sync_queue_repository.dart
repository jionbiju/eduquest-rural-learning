import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/sync_action.dart';

/// Manages the local Hive queue of pending sync actions.
/// Actions are written here first (offline-safe), then
/// flushed to Firestore by [SyncService] when connectivity is available.
class SyncQueueRepository {
  Box<String>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(AppConstants.hiveSyncQueueBox);
  }

  Box<String> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError('SyncQueueRepository not initialised. Call init() first.');
    }
    return _box!;
  }

  /// Adds an action to the queue.
  Future<void> enqueue(SyncAction action) async {
    await _safeBox.put(action.id, jsonEncode(action.toJson()));
  }

  /// Returns all pending actions ordered by creation time.
  List<SyncAction> getPending() {
    return _safeBox.values
        .map((v) => SyncAction.fromJson(jsonDecode(v) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Removes a successfully synced action from the queue.
  Future<void> remove(String actionId) async {
    await _safeBox.delete(actionId);
  }

  /// Increments retry count for a failed action.
  Future<void> incrementRetry(String actionId) async {
    final raw = _safeBox.get(actionId);
    if (raw == null) return;
    final action =
        SyncAction.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    action.retryCount++;
    await _safeBox.put(actionId, jsonEncode(action.toJson()));
  }

  /// Clears all pending actions (use with caution).
  Future<void> clearAll() async {
    await _safeBox.clear();
  }

  int get pendingCount => _safeBox.length;
}
