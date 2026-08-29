import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../home/providers/home_provider.dart';
import '../../providers/lesson_provider.dart';
import '../widgets/difficulty_badge.dart';
import '../widgets/interactive_lesson_playground.dart';
import '../widgets/lesson_illustration.dart';

/// Displays a single topic lesson with text, illustration, live audio voice narration (TTS),
/// and a topic-specific interactive playground.
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.topicId});

  final String topicId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  int _activeSentenceIndex = -1;
  double _playbackProgress = 0.0;
  List<String> _sentences = [];
  String _currentLocale = 'en';

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      final isHindi = _currentLocale == 'hi';
      final langCode = isHindi ? 'hi-IN' : 'en-US';
      await _flutterTts.setLanguage(langCode);
      await _flutterTts.setSpeechRate(0.50); // Natural, clear conversational rate
      await _flutterTts.setPitch(1.05); // Friendly, clear teacher pitch
      await _flutterTts.setVolume(1.0);

      // Attempt to pick high quality natural human voice
      try {
        final voices = await _flutterTts.getVoices;
        if (voices is List && voices.isNotEmpty) {
          final voiceList = voices.cast<Map>();
          Map? selectedVoice;
          for (final v in voiceList) {
            final name = (v['name'] ?? '').toString().toLowerCase();
            final locale = (v['locale'] ?? v['lang'] ?? '').toString().toLowerCase();

            if (isHindi) {
              if (locale.contains('hi') || name.contains('hindi') || name.contains('india')) {
                selectedVoice = v;
                break;
              }
            } else {
              // Prefer natural, neural, google, siri, or edge natural voices
              if (name.contains('natural') ||
                  name.contains('neural') ||
                  name.contains('wavenet') ||
                  name.contains('journey') ||
                  name.contains('google us') ||
                  name.contains('samantha') ||
                  name.contains('jenny') ||
                  name.contains('guy')) {
                selectedVoice = v;
                break;
              }
            }
          }

          if (selectedVoice != null) {
            await _flutterTts.setVoice({
              "name": selectedVoice['name'],
              "locale": selectedVoice['locale'] ?? selectedVoice['lang'] ?? langCode,
            });
          }
        }
      } catch (_) {}

      _flutterTts.setCompletionHandler(() {
        if (!mounted || !_isPlaying) return;
        if (_activeSentenceIndex < _sentences.length - 1) {
          _speakSentence(_activeSentenceIndex + 1);
        } else {
          _onLessonNarrationCompleted();
        }
      });

      _flutterTts.setErrorHandler((msg) {
        if (!mounted) return;
        _stopNarration();
      });

      _flutterTts.setCancelHandler(() {
        if (!mounted) return;
        setState(() => _isPlaying = false);
      });
    } catch (_) {
      // Graceful fallback if TTS fails on specific platform
    }
  }

  void _onLessonNarrationCompleted() {
    _stopNarration();
    // Award 15 XP for completing the audio lesson read-along!
    ref.read(studentProfileProvider.notifier).addXp(15);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Text('⭐', style: TextStyle(fontSize: 20)),
            SizedBox(width: 10),
            Text(
              'Awesome! +15 XP earned for listening to the lesson!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _speakSentence(int index) async {
    if (index < 0 || index >= _sentences.length) {
      _stopNarration();
      return;
    }

    setState(() {
      _isPlaying = true;
      _activeSentenceIndex = index;
      _playbackProgress = (index + 1) / _sentences.length;
    });

    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage(_currentLocale == 'hi' ? 'hi-IN' : 'en-US');
      await _flutterTts.speak(_sentences[index]);
    } catch (_) {
      // Fallback
    }
  }

  void _startNarration() {
    if (_sentences.isEmpty) return;

    final targetIndex = (_activeSentenceIndex == -1 || _activeSentenceIndex >= _sentences.length - 1)
        ? 0
        : _activeSentenceIndex;

    _speakSentence(targetIndex);
  }

  Future<void> _stopNarration() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _toggleNarration() {
    if (_isPlaying) {
      _stopNarration();
    } else {
      _startNarration();
    }
  }

  Future<void> _resetNarration() async {
    await _stopNarration();
    if (mounted) {
      setState(() {
        _activeSentenceIndex = -1;
        _playbackProgress = 0.0;
      });
    }
  }

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
    _flutterTts.stop();
    super.dispose();
  }

  /// Maps topicId prefix to an emoji for illustrations.
  String _emojiForTopic(String id) {
    if (id.startsWith('math')) return '🔢';
    if (id.startsWith('science_plants')) return '🌱';
    if (id.startsWith('science_water')) return '💧';
    if (id.startsWith('science_animals')) return '🐾';
    if (id.startsWith('english')) return '📖';
    if (id.startsWith('history')) return '🏛️';
    return '📚';
  }

  List<String> _splitIntoSentences(String text) {
    // Splits by period (English) or danda (Hindi).
    final reg = RegExp(r'[.।]+');
    return text
        .split(reg)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final topicAsync = ref.watch(topicByIdProvider(widget.topicId));
    const locale = 'en'; // Defaults to English
    _currentLocale = locale;

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

                      // ── Lesson content with Voice Narration ────────────
                      Row(
                        children: [
                          const Text('🔊', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            'Lesson Voice Read-Along',
                            style: AppTextStyles.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap Play to hear audio narration or tap any sentence to listen.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
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
                            // Voice Narration controls
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isPlaying
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_filled_rounded,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: _toggleNarration,
                                  tooltip: _isPlaying ? 'Pause Narration' : 'Play Voice Narration',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.replay_circle_filled_rounded,
                                    size: 30,
                                    color: AppColors.grey600,
                                  ),
                                  onPressed: _resetNarration,
                                  tooltip: 'Restart from beginning',
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _isPlaying ? 'Speaking aloud... 🔊' : 'Audio Ready',
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: _isPlaying ? AppColors.primary : AppColors.grey600,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${(_playbackProgress * 100).toInt()}%',
                                            style: AppTextStyles.labelSmall,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: _playbackProgress,
                                          backgroundColor: AppColors.grey200,
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            // RichText with clickable sentence spans
                            RichText(
                              text: TextSpan(
                                children: List.generate(_sentences.length, (index) {
                                  final isHighlighted = index == _activeSentenceIndex;
                                  return TextSpan(
                                    text: '${_sentences[index]}. ',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _speakSentence(index),
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      height: 1.7,
                                      backgroundColor: isHighlighted
                                          ? AppColors.primary.withValues(alpha: 0.2)
                                          : Colors.transparent,
                                      color: isHighlighted
                                          ? AppColors.primaryDark
                                          : AppColors.grey800,
                                      fontWeight: isHighlighted
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      decoration: isHighlighted ? TextDecoration.underline : TextDecoration.none,
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
