import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/topic_model.dart';
import '../data/repositories/bundle_repository.dart';

/// Provides a single topic by its ID for the lesson screen.
final topicByIdProvider =
    FutureProvider.family<TopicModel?, String>((ref, topicId) async {
  final subjects = await ref.watch(subjectsProvider.future);
  for (final subject in subjects) {
    try {
      return subject.topics.firstWhere((t) => t.id == topicId);
    } catch (_) {
      continue;
    }
  }
  return null;
});

/// Tracks whether the current lesson has been completed.
final lessonCompletedProvider =
    StateProvider.family<bool, String>((ref, topicId) => false);
