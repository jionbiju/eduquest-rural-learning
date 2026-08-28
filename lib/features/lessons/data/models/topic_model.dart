import 'question_model.dart';

/// A topic within a subject — contains lesson text, audio ref and questions.
class TopicModel {
  const TopicModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.audioRef,
    required this.illustrationRef,
    required this.lessonText,
    required this.questions,
  });

  final String id;
  final Map<String, String> name;         // locale → name
  final int difficulty;
  final String audioRef;
  final String illustrationRef;
  final Map<String, String> lessonText;   // locale → lesson text
  final List<QuestionModel> questions;

  String localizedName(String locale) =>
      name[locale] ?? name['en'] ?? id;

  String localizedLessonText(String locale) =>
      lessonText[locale] ?? lessonText['en'] ?? '';

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as String,
      name: Map<String, String>.from(json['name'] as Map),
      difficulty: (json['difficulty'] as num).toInt(),
      audioRef: json['audioRef'] as String? ?? '',
      illustrationRef: json['illustrationRef'] as String? ?? '',
      lessonText: Map<String, String>.from(json['lessonText'] as Map),
      questions: (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'difficulty': difficulty,
        'audioRef': audioRef,
        'illustrationRef': illustrationRef,
        'lessonText': lessonText,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}
