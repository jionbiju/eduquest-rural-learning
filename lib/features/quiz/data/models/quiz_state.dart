import '../../../lessons/data/models/question_model.dart';

/// Represents the current state of an active quiz session.
class QuizState {
  const QuizState({
    required this.questions,
    this.currentIndex = 0,
    this.selectedAnswer,
    this.isAnswered = false,
    this.isCorrect = false,
    this.xpEarned = 0,
    this.correctCount = 0,
    this.rollingAnswers = const [],
    this.isCompleted = false,
  });

  final List<QuestionModel> questions;
  final int currentIndex;
  final int? selectedAnswer;
  final bool isAnswered;
  final bool isCorrect;
  final int xpEarned;
  final int correctCount;

  /// Rolling window of booleans — true = correct, false = wrong.
  /// Used for adaptive difficulty calculation.
  final List<bool> rollingAnswers;

  final bool isCompleted;

  QuestionModel get currentQuestion => questions[currentIndex];
  bool get isLastQuestion => currentIndex == questions.length - 1;
  int get totalQuestions => questions.length;

  /// Rolling accuracy over the last N answers.
  double get rollingAccuracy {
    if (rollingAnswers.isEmpty) return 0.5;
    final correct = rollingAnswers.where((a) => a).length;
    return correct / rollingAnswers.length;
  }

  QuizState copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    int? selectedAnswer,
    bool? isAnswered,
    bool? isCorrect,
    int? xpEarned,
    int? correctCount,
    List<bool>? rollingAnswers,
    bool? isCompleted,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
      xpEarned: xpEarned ?? this.xpEarned,
      correctCount: correctCount ?? this.correctCount,
      rollingAnswers: rollingAnswers ?? this.rollingAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
