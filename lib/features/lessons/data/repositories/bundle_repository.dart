import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/subject_model.dart';

/// Loads and parses the local content bundle from assets.
class BundleRepository {
  BundleRepository();

  List<SubjectModel>? _cached;

  Future<List<SubjectModel>> loadSubjects() async {
    if (_cached != null) return _cached!;

    final raw = await rootBundle.loadString(AppConstants.bundlePath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final subjects = (json['subjects'] as List)
        .map((s) => SubjectModel.fromJson(s as Map<String, dynamic>))
        .toList();

    _cached = subjects;
    return subjects;
  }

  Future<SubjectModel?> getSubjectById(String id) async {
    final subjects = await loadSubjects();
    try {
      return subjects.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Riverpod provider for the bundle repository.
final bundleRepositoryProvider = Provider<BundleRepository>(
  (ref) => BundleRepository(),
);

/// Async provider that loads all subjects from the bundle.
final subjectsProvider = FutureProvider<List<SubjectModel>>((ref) {
  return ref.watch(bundleRepositoryProvider).loadSubjects();
});
