import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../lessons/data/models/question_model.dart';
import '../../lessons/providers/lesson_provider.dart';
import '../data/models/quiz_state.dart';

/// Provides the quiz session for a given topicId.
final quizProvider =
    StateNotifierProvider.family<QuizNotifier, QuizState, String>(
  (ref, topicId) => QuizNotifier(ref, topicId),
);

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(this._ref, this._topicId)
      : super(const QuizState(questions: [])) {
    _init();
  }

  final Ref _ref;
  final String _topicId;

  Future<void> _init() async {
    final topic = await _ref.read(topicByIdProvider(_topicId).future);
    if (topic == null) return;

    // Group questions by difficulty, shuffle each group, then combine.
    final rng = Random();
    final groups = <int, List<QuestionModel>>{};
    for (final q in topic.questions) {
      groups.putIfAbsent(q.difficulty, () => []).add(q);
    }
    final shuffled = <QuestionModel>[];
    final sortedKeys = groups.keys.toList()..sort();
    for (final key in sortedKeys) {
      final group = groups[key]!..shuffle(rng);
      shuffled.addAll(group);
    }

    state = QuizState(questions: shuffled);
  }

  /// Called when the student taps an answer option.
  void selectAnswer(int index) {
    if (state.isAnswered) return;

    final correct = index == state.currentQuestion.correctIndex;
    final xp = correct ? _xpForDifficulty(state.currentQuestion.difficulty) : 0;

    // Update rolling window (capped at window size).
    final updated = [...state.rollingAnswers, correct];
    final window = updated.length > AppConstants.rollingAccuracyWindow
        ? updated.sublist(updated.length - AppConstants.rollingAccuracyWindow)
        : updated;

    state = state.copyWith(
      selectedAnswer: index,
      isAnswered: true,
      isCorrect: correct,
      xpEarned: state.xpEarned + xp,
      correctCount: correct ? state.correctCount + 1 : state.correctCount,
      rollingAnswers: window,
    );
  }

  /// Advances to the next question, reordering remaining questions
  /// based on current rolling accuracy (adaptive difficulty).
  void nextQuestion() {
    if (state.isLastQuestion) {
      state = state.copyWith(isCompleted: true);
      // Award lesson completion XP.
      _ref.read(lessonCompletedProvider(_topicId).notifier).state = true;
      return;
    }

    final nextIndex = state.currentIndex + 1;
    final remaining =
        state.questions.sublist(nextIndex).toList();

    // Adapt: if accuracy is high, push harder questions forward.
    // If accuracy is low, push easier questions forward.
    final accuracy = state.rollingAccuracy;
    if (accuracy >= AppConstants.accuracyThresholdUp) {
      remaining.sort((a, b) => b.difficulty.compareTo(a.difficulty));
    } else if (accuracy <= AppConstants.accuracyThresholdDown) {
      remaining.sort((a, b) => a.difficulty.compareTo(b.difficulty));
    }

    final reordered = [
      ...state.questions.sublist(0, nextIndex),
      ...remaining,
    ];

    state = state.copyWith(
      questions: reordered,
      currentIndex: nextIndex,
      selectedAnswer: null,
      isAnswered: false,
      isCorrect: false,
    );
  }

  void resetQuiz() {
    // Reset all state fields first, then reload questions with new shuffle.
    state = const QuizState(questions: []);
    _init();
  }

  int _xpForDifficulty(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppConstants.xpPerCorrectAnswer;
      case 2:
        return (AppConstants.xpPerCorrectAnswer * 1.5).toInt();
      case 3:
        return AppConstants.xpPerCorrectAnswer * 2;
      default:
        return AppConstants.xpPerCorrectAnswer;
    }
  }
}
