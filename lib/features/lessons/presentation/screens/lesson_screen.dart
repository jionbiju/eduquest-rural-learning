import 'package:flutter/foundation.dart';
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
import '../../../settings/providers/settings_provider.dart';
import '../../providers/lesson_provider.dart';
import '../widgets/difficulty_badge.dart';
import '../widgets/interactive_lesson_playground.dart';
import '../widgets/lesson_illustration.dart';
import 'tts_stub.dart' if (dart.library.js_interop) 'tts_web.dart';

/// Displays a single topic lesson with text, illustration, live audio voice narration (TTS),
/// bilingual Language Tabs (Hindi / English), and an interactive playground.
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
  String _currentLocale = 'hi'; // Default to Hindi active tab

  @override
  void initState() {
    super.initState();
    // Default current locale to global selected language (which defaults to 'hi')
    _currentLocale = ref.read(selectedLanguageProvider);
    if (!kIsWeb) {
      _initNativeTts();
    }
  }

  Future<void> _initNativeTts() async {
    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isPlaying = true);
    });

    _flutterTts.setCompletionHandler(() {
      if (!mounted || !_isPlaying) return;
      if (_activeSentenceIndex < _sentences.length - 1) {
        _speakSentence(_activeSentenceIndex + 1);
      } else {
        _onLessonNarrationCompleted();
      }
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint('TTS native error: $msg');
      if (!mounted) return;
      _stopNarration();
    });

    _flutterTts.setCancelHandler(() {
      if (!mounted) return;
      setState(() => _isPlaying = false);
    });

    await _configureNativeTts(_currentLocale);
  }

  Future<void> _configureNativeTts(String locale) async {
    final isHindi = locale == 'hi';
    final langCode = isHindi ? 'hi-IN' : 'en-US';

    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage(langCode);
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);

      try {
        final dynamic voices = await _flutterTts.getVoices;
        if (voices is List && voices.isNotEmpty) {
          Map<String, String>? bestVoice;
          for (final item in voices) {
            if (item is Map) {
              final name = (item['name'] ?? '').toString();
              final voiceLocale = (item['locale'] ?? item['lang'] ?? '').toString();
              final nameLower = name.toLowerCase();
              final locLower = voiceLocale.toLowerCase();

              if (isHindi) {
                if (locLower.contains('hi') ||
                    nameLower.contains('hindi') ||
                    nameLower.contains('हिन्दी') ||
                    nameLower.contains('india')) {
                  bestVoice = {
                    'name': name,
                    'locale': voiceLocale.isNotEmpty ? voiceLocale : 'hi-IN'
                  };
                  break;
                }
              } else {
                if (locLower.contains('en') &&
                    (nameLower.contains('natural') ||
                        nameLower.contains('google') ||
                        nameLower.contains('jenny') ||
                        nameLower.contains('guy'))) {
                  bestVoice = {
                    'name': name,
                    'locale': voiceLocale.isNotEmpty ? voiceLocale : 'en-US'
                  };
                  break;
                }
              }
            }
          }

          if (bestVoice != null) {
            await _flutterTts.setVoice(bestVoice);
          }
        }
      } catch (_) {}
    } catch (_) {}
  }

  void _onLessonNarrationCompleted() {
    _stopNarration();
    // Award 15 XP for completing the audio lesson read-along!
    ref.read(studentProfileProvider.notifier).addXp(15);
    final isHindi = _currentLocale == 'hi';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isHindi
                    ? 'शानदार! पाठ सुनने के लिए +15 XP मिले!'
                    : 'Awesome! +15 XP earned for listening to the lesson!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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

    final textToSpeak = _sentences[index].trim();
    if (textToSpeak.isEmpty) {
      if (index < _sentences.length - 1) {
        _speakSentence(index + 1);
      } else {
        _onLessonNarrationCompleted();
      }
      return;
    }

    setState(() {
      _isPlaying = true;
      _activeSentenceIndex = index;
      _playbackProgress = (index + 1) / _sentences.length;
    });

    if (kIsWeb) {
      try {
        final onEnd = () {
          if (!mounted || !_isPlaying) return;
          if (_activeSentenceIndex < _sentences.length - 1) {
            _speakSentence(_activeSentenceIndex + 1);
          } else {
            _onLessonNarrationCompleted();
          }
        };

        final onError = (dynamic _) {
          if (!mounted) return;
          _stopNarration();
        };

        playWebTts(textToSpeak, _currentLocale, onEnd, onError);
      } catch (e) {
        debugPrint('Web TTS fallback error: $e');
        // Fallback to flutter_tts
        try {
          await _flutterTts.stop();
          await _flutterTts.setLanguage(_currentLocale == 'hi' ? 'hi-IN' : 'en-US');
          await _flutterTts.speak(textToSpeak);
        } catch (_) {}
      }
    } else {
      try {
        await _flutterTts.stop();
        final isHindi = _currentLocale == 'hi';
        await _flutterTts.setLanguage(isHindi ? 'hi-IN' : 'en-US');
        await _flutterTts.speak(textToSpeak);
      } catch (e) {
        debugPrint('Native TTS error: $e');
      }
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
    if (kIsWeb) {
      try {
        stopWebTts();
      } catch (_) {}
    } else {
      try {
        await _flutterTts.stop();
      } catch (_) {}
    }
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

  void _switchLanguage(String newLocale, String newText) {
    if (_currentLocale == newLocale) return;
    _stopNarration();
    setState(() {
      _currentLocale = newLocale;
      _activeSentenceIndex = -1;
      _playbackProgress = 0.0;
      _sentences = _splitIntoSentences(newText);
    });
    ref.read(selectedLanguageProvider.notifier).state = newLocale;
    if (!kIsWeb) {
      _configureNativeTts(newLocale);
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
    _stopNarration();
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
    // Splits by period (English), danda (Hindi), or newline
    final reg = RegExp(r'[.।\n]+');
    return text
        .split(reg)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final topicAsync = ref.watch(topicByIdProvider(widget.topicId));

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

          // Keep current locale in sync with selection
          final locale = _currentLocale;
          final isHindi = locale == 'hi';

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
                    fontWeight: FontWeight.bold,
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
                      // ── Language Selector Tabs (Hindi Active by default) ────
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: Row(
                          children: [
                            // Hindi Tab (Active by default)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _switchLanguage('hi', topic.localizedLessonText('hi')),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isHindi ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: isHindi
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'हिन्दी (Hindi)',
                                        style: AppTextStyles.labelLarge.copyWith(
                                          color: isHindi ? Colors.white : AppColors.grey600,
                                          fontWeight: isHindi ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                      if (isHindi) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // English Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _switchLanguage('en', topic.localizedLessonText('en')),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !isHindi ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: !isHindi
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('🇬🇧', style: TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'English',
                                        style: AppTextStyles.labelLarge.copyWith(
                                          color: !isHindi ? Colors.white : AppColors.grey600,
                                          fontWeight: !isHindi ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                      if (!isHindi) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

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
                            isHindi ? 'इंटरैक्टिव अभ्यास (Interactive Play)' : 'Interactive Play',
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
                            isHindi ? 'पाठ वाचन (Voice Read-Along)' : 'Lesson Voice Read-Along',
                            style: AppTextStyles.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHindi
                            ? 'ऑडियो सुनने के लिए Play दबाएं या किसी भी वाक्य पर टैप करें।'
                            : 'Tap Play to hear audio narration or tap any sentence to listen.',
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
                                  tooltip: _isPlaying
                                      ? (isHindi ? 'रोकें (Pause)' : 'Pause Narration')
                                      : (isHindi ? 'पाठ सुनें (Play Voice Narration)' : 'Play Voice Narration'),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.replay_circle_filled_rounded,
                                    size: 30,
                                    color: AppColors.grey600,
                                  ),
                                  onPressed: _resetNarration,
                                  tooltip: isHindi ? 'शुरू से दोबारा सुनें' : 'Restart from beginning',
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
                                            _isPlaying
                                                ? (isHindi ? 'वाचन चल रहा है... 🔊' : 'Speaking aloud... 🔊')
                                                : (isHindi ? 'ऑडियो तैयार है 🇮🇳' : 'Audio Ready 🇬🇧'),
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
                                  final delimiter = isHindi ? '। ' : '. ';
                                  return TextSpan(
                                    text: '${_sentences[index]}$delimiter',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _speakSentence(index),
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      height: 1.8,
                                      fontSize: 17,
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
                                isHindi
                                    ? '${topic.questions.length} प्रश्न तैयार हैं — ${topic.questions.length * AppConstants.xpPerCorrectAnswer + AppConstants.xpPerLessonComplete} XP तक अर्जित करें'
                                    : '${topic.questions.length} questions ready — '
                                        'earn up to ${topic.questions.length * AppConstants.xpPerLessonComplete} XP',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Start Quiz CTA ────────────────────────────────
                      PrimaryButton(
                        label: isHindi ? 'प्रश्नोत्तरी शुरू करें (Start Quiz)' : 'Start Quiz',
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
                          child: Text(isHindi ? 'विषयों पर वापस जाएं (Back to Subjects)' : 'Back to Subjects'),
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
