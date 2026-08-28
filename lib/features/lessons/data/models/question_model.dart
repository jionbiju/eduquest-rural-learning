/// A single quiz question inside a topic.
class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.difficulty,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final int difficulty; // 1 = easy, 2 = medium, 3 = hard
  final Map<String, String> text;       // locale → text
  final List<String> options;
  final int correctIndex;
  final Map<String, String> explanation; // locale → explanation

  String localizedText(String locale) =>
      text[locale] ?? text['en'] ?? '';

  String localizedExplanation(String locale) =>
      explanation[locale] ?? explanation['en'] ?? '';

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      difficulty: (json['difficulty'] as num).toInt(),
      text: Map<String, String>.from(json['text'] as Map),
      options: List<String>.from(json['options'] as List),
      correctIndex: (json['correctIndex'] as num).toInt(),
      explanation: Map<String, String>.from(json['explanation'] as Map),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'difficulty': difficulty,
        'text': text,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}
