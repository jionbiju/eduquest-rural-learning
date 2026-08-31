import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../data/models/subject_model.dart';
import '../../data/models/topic_model.dart';
import '../../data/repositories/bundle_repository.dart';

/// Screen that lists all subjects and their topics from the content bundle.
class LessonsListScreen extends ConsumerWidget {
  const LessonsListScreen({super.key});

  static const _subjectColors = [
    AppColors.primary,
    AppColors.success,
    AppColors.secondary,
    AppColors.badgePurple,
    AppColors.xpGold,
  ];

  static const _subjectEmojis = <String, String>{
    'math': '🔢',
    'science': '🔬',
    'english': '📖',
    'history': '🏛️',
    'geography': '🌍',
  };

  Color _colorForIndex(int i) => _subjectColors[i % _subjectColors.length];

  String _emojiForSubject(SubjectModel subject) {
    for (final entry in _subjectEmojis.entries) {
      if (subject.id.startsWith(entry.key)) return entry.value;
    }
    return '📚';
  }

  String _emojiForTopic(TopicModel topic) {
    if (topic.id.startsWith('math')) return '🔢';
    if (topic.id.startsWith('science_plants')) return '🌱';
    if (topic.id.startsWith('science_water')) return '💧';
    if (topic.id.startsWith('science_animals')) return '🐾';
    if (topic.id.startsWith('english')) return '📖';
    if (topic.id.startsWith('history')) return '🏛️';
    return '📄';
  }

  Color _difficultyColor(int d) {
    if (d == 1) return AppColors.success;
    if (d == 2) return AppColors.secondary;
    return AppColors.error;
  }

  String _difficultyLabel(int d, String locale) {
    final isHindi = locale == 'hi';
    if (d == 1) return isHindi ? 'सरल' : 'Easy';
    if (d == 2) return isHindi ? 'मध्यम' : 'Medium';
    return isHindi ? 'कठिन' : 'Hard';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);
    final isHindi = selectedLang == 'hi';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isHindi ? 'पाठ एवं विषय (Lessons)' : 'Lessons',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 48, right: 20),
                    child: Text('📚', style: TextStyle(fontSize: 52)),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          subjectsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Could not load lessons: $e',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
            data: (subjects) {
              if (subjects.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      isHindi ? 'कोई पाठ उपलब्ध नहीं है।' : 'No lessons available.',
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final subject = subjects[i];
                    final color = _colorForIndex(i);
                    return _SubjectSection(
                      subject: subject,
                      color: color,
                      locale: selectedLang,
                      subjectEmoji: _emojiForSubject(subject),
                      topicEmojiBuilder: _emojiForTopic,
                      difficultyColorBuilder: _difficultyColor,
                      difficultyLabelBuilder: (d) => _difficultyLabel(d, selectedLang),
                    );
                  },
                  childCount: subjects.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Subject section (collapsible) ─────────────────────────────────────────────

class _SubjectSection extends StatefulWidget {
  const _SubjectSection({
    required this.subject,
    required this.color,
    required this.locale,
    required this.subjectEmoji,
    required this.topicEmojiBuilder,
    required this.difficultyColorBuilder,
    required this.difficultyLabelBuilder,
  });

  final SubjectModel subject;
  final Color color;
  final String locale;
  final String subjectEmoji;
  final String Function(TopicModel) topicEmojiBuilder;
  final Color Function(int) difficultyColorBuilder;
  final String Function(int) difficultyLabelBuilder;

  @override
  State<_SubjectSection> createState() => _SubjectSectionState();
}

class _SubjectSectionState extends State<_SubjectSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final isHindi = widget.locale == 'hi';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Subject header ──────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.subjectEmoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subject.localizedName(widget.locale),
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.grey800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isHindi
                              ? '${widget.subject.topics.length} विषय (Topics)'
                              : '${widget.subject.topics.length} topics',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: widget.color,
                  ),
                ],
              ),
            ),
          ),

          // ── Topic tiles ─────────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: Column(
              children: widget.subject.topics.map((topic) {
                return _TopicTile(
                  topic: topic,
                  color: widget.color,
                  locale: widget.locale,
                  emoji: widget.topicEmojiBuilder(topic),
                  difficultyColor:
                      widget.difficultyColorBuilder(topic.difficulty),
                  difficultyLabel:
                      widget.difficultyLabelBuilder(topic.difficulty),
                );
              }).toList(),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// ── Individual topic tile ─────────────────────────────────────────────────────

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.topic,
    required this.color,
    required this.locale,
    required this.emoji,
    required this.difficultyColor,
    required this.difficultyLabel,
  });

  final TopicModel topic;
  final Color color;
  final String locale;
  final String emoji;
  final Color difficultyColor;
  final String difficultyLabel;

  @override
  Widget build(BuildContext context) {
    final isHindi = locale == 'hi';
    return GestureDetector(
      onTap: () => context.goNamed(
        'lesson',
        pathParameters: {'lessonId': topic.id},
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            // Topic info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.localizedName(locale),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          difficultyLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: difficultyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isHindi ? '${topic.questions.length} प्रश्न' : '${topic.questions.length} questions',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
