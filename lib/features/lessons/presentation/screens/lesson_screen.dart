import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../providers/lesson_provider.dart';
import '../widgets/difficulty_badge.dart';
import '../widgets/interactive_lesson_playground.dart';
import '../widgets/lesson_illustration.dart';

/// Displays a single topic lesson with text, illustration, audio narration simulation,
/// and a topic-specific interactive playground.
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.topicId});

  final String topicId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  bool _isPlaying = false;
  int _activeSentenceIndex = -1;
  double _playbackProgress = 0.0;
  Timer? _narrationTimer;
  List<String> _sentences = [];

  @override
  void didUpdateWidget(covariant LessonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicId != widget.topicId) {
      _stopNarration();
      _activeSentenceIndex = -1;
      _playbackProgress = 0.0;
      _sentences = [];
    }
  }

  @override
  void dispose() {
    _narrationTimer?.cancel();
    super.dispose();
  }

  /// Maps topicId prefix to an emoji for illustrations.
  String _emojiForTopic(String id) {
    if (id.startsWith('math')) return '🔢';
    if (id.startsWith('science_plants')) return '🌱';
    if (id.startsWith('science_water')) return '💧';
    if (id.startsWith('science_animals')) return '🐾';
    return '📚';
  }

  void _startNarration() {
    if (_sentences.isEmpty) return;

    setState(() {
      _isPlaying = true;
      if (_activeSentenceIndex == -1 || _activeSentenceIndex >= _sentences.length - 1) {
        _activeSentenceIndex = 0;
      }
      _playbackProgress = (_activeSentenceIndex + 1) / _sentences.length;
    });

    _narrationTimer?.cancel();
    _narrationTimer = Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      if (_activeSentenceIndex < _sentences.length - 1) {
        setState(() {
          _activeSentenceIndex++;
          _playbackProgress = (_activeSentenceIndex + 1) / _sentences.length;
        });
      } else {
        _stopNarration();
      }
    });
  }

  void _stopNarration() {
    _narrationTimer?.cancel();
    setState(() {
      _isPlaying = false;
    });
  }

  void _toggleNarration() {
    if (_isPlaying) {
      _stopNarration();
    } else {
      _startNarration();
    }
  }

  void _resetNarration() {
    _stopNarration();
    setState(() {
      _activeSentenceIndex = -1;
      _playbackProgress = 0.0;
    });
  }

  List<String> _splitIntoSentences(String text) {
    // Splits by period (English) or danda (Hindi).
    final reg = RegExp(RegExp.escape('.') + '|' + RegExp.escape('।'));
    return text.split(reg).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topicAsync = ref.watch(topicByIdProvider(widget.topicId));
    const locale = 'en'; // Defaults to English

    return Scaffold(
      backgroundColor: AppColors.background,
      body: topicAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text('Could not load lesson: $e'),
        ),
        data: (topic) {
          if (topic == null) {
            return Center(
              child: Text(
                'Lesson not found',
                style: AppTextStyles.headlineMedium,
              ),
            );
          }

          final lessonText = topic.localizedLessonText(locale);
          if (_sentences.isEmpty) {
            _sentences = _splitIntoSentences(lessonText);
          }

          return CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  topic.localizedName(locale),
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: DifficultyBadge(difficulty: topic.difficulty),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Illustration ──────────────────────────────────
                      LessonIllustration(
                        illustrationRef: topic.illustrationRef,
                        subjectEmoji: _emojiForTopic(topic.id),
                      ),
                      const SizedBox(height: 24),

                      // ── Interactive Playground Section ─────────────────
                      Row(
                        children: [
                          const Text('🎮', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            'Interactive Play',
                            style: AppTextStyles.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InteractiveLessonPlayground(topicId: topic.id),
                      const SizedBox(height: 28),

                      // ── Lesson content with Narration ──────────────────
                      Row(
                        children: [
                          const Text('📝', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            'Lesson Read-Along',
                            style: AppTextStyles.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.grey200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Narration controls
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isPlaying
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_filled_rounded,
                                    size: 38,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: _toggleNarration,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.replay_circle_filled_rounded,
                                    size: 28,
                                    color: AppColors.grey600,
                                  ),
                                  onPressed: _resetNarration,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: _playbackProgress,
                                      backgroundColor: AppColors.grey200,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            // RichText for narration sentence highlighting
                            RichText(
                              text: TextSpan(
                                children: List.generate(_sentences.length, (index) {
                                  final isHighlighted = index == _activeSentenceIndex;
                                  return TextSpan(
                                    text: '${_sentences[index]}. ',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      height: 1.7,
                                      backgroundColor: isHighlighted
                                          ? AppColors.primary.withValues(alpha: 0.18)
                                          : Colors.transparent,
                                      color: isHighlighted
                                          ? AppColors.primaryDark
                                          : AppColors.grey800,
                                      fontWeight: isHighlighted
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Question count info ───────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.quiz_outlined,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${topic.questions.length} questions ready — '
                                'earn up to ${topic.questions.length * AppConstants.xpPerCorrectAnswer + AppConstants.xpPerLessonComplete} XP',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Start Quiz CTA ────────────────────────────────
                      PrimaryButton(
                        label: 'Start Quiz',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => context.goNamed(
                          'quiz',
                          pathParameters: {'lessonId': widget.topicId},
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Back to Subjects'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
