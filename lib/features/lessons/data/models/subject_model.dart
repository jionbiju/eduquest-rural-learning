import 'topic_model.dart';

/// A subject containing multiple topics (e.g. Mathematics, Science).
class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.topics,
  });

  final String id;
  final Map<String, String> name; // locale → name
  final String icon;
  final List<TopicModel> topics;

  String localizedName(String locale) =>
      name[locale] ?? name['en'] ?? id;

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      name: Map<String, String>.from(json['name'] as Map),
      icon: json['icon'] as String? ?? '',
      topics: (json['topics'] as List)
          .map((t) => TopicModel.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'topics': topics.map((t) => t.toJson()).toList(),
      };
}
