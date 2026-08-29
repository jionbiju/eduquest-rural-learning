import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Renders a dynamic, premium interactive game/playground for a given topic.
class InteractiveLessonPlayground extends StatelessWidget {
  const InteractiveLessonPlayground({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    if (topicId == 'math_addition') {
      return const _AdditionPlayground();
    } else if (topicId == 'math_subtraction') {
      return const _SubtractionPlayground();
    } else if (topicId == 'math_multiplication') {
      return const _MultiplicationPlayground();
    } else if (topicId == 'science_plants') {
      return const _PlantsPlayground();
    } else if (topicId == 'science_water') {
      return const _WaterCyclePlayground();
    } else if (topicId == 'science_animals') {
      return const _AnimalsPlayground();
    } else if (topicId == 'english_nouns') {
      return const _EnglishNounsPlayground();
    } else if (topicId == 'english_verbs') {
      return const _EnglishVerbsPlayground();
    } else if (topicId == 'history_ancient') {
      return const _HistoryAncientPlayground();
    } else if (topicId == 'history_independence') {
      return const _HistoryIndependencePlayground();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: const Center(
        child: Text('Interactive simulator loading...', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

// ── 1. MATHEMATICS: ADDITION SIMULATOR ────────────────────────────────────────

class _AdditionPlayground extends StatefulWidget {
  const _AdditionPlayground();

  @override
  State<_AdditionPlayground> createState() => _AdditionPlaygroundState();
}

class _AdditionPlaygroundState extends State<_AdditionPlayground> {
  int _left = 3;
  int _right = 4;
  bool _isCombined = false;
  int _countingIndex = 0;
  Timer? _timer;

  void _combine() {
    setState(() {
      _isCombined = true;
      _countingIndex = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (_countingIndex < _left + _right) {
        setState(() {
          _countingIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isCombined = false;
      _countingIndex = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interactive Addition', style: AppTextStyles.headlineSmall),
              IconButton(onPressed: _reset, icon: const Icon(Icons.refresh_rounded, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),

          // Control panel
          if (!_isCombined) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _counterControl('Left', _left, (v) => setState(() => _left = v)),
                const Text('+', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                _counterControl('Right', _right, (v) => setState(() => _right = v)),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Visual board
          Container(
            padding: const EdgeInsets.all(16),
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: _isCombined ? _combinedView() : _separateView(),
          ),
          const SizedBox(height: 16),

          // Sum expression
          if (_isCombined) ...[
            Text(
              '$_left + $_right = ${_left + _right}',
              style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              _countingIndex == _left + _right ? 'Combined successfully! 🎉' : 'Counting... $_countingIndex',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _countingIndex == _left + _right ? AppColors.success : AppColors.grey600,
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _combine,
                icon: const Icon(Icons.merge_type_rounded),
                label: const Text('Combine & Count!'),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _counterControl(String label, int val, ValueChanged<int> onChange) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Row(
          children: [
            IconButton(
              onPressed: val > 1 ? () => onChange(val - 1) : null,
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
            Text('$val', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: val < 6 ? () => onChange(val + 1) : null,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ],
        )
      ],
    );
  }

  Widget _separateView() {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: List.generate(_left, (_) => _apple(AppColors.primary)),
          ),
        ),
        const VerticalDivider(thickness: 1.5),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: List.generate(_right, (_) => _apple(AppColors.secondary)),
          ),
        ),
      ],
    );
  }

  Widget _combinedView() {
    return Center(
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: List.generate(_left + _right, (i) {
          final isHighlighted = i < _countingIndex;
          final color = i < _left ? AppColors.primary : AppColors.secondary;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.diagonal3Values(
              isHighlighted ? 1.15 : 1.0,
              isHighlighted ? 1.15 : 1.0,
              1.0,
            ),
            child: _apple(isHighlighted ? color : AppColors.grey200),
          );
        }),
      ),
    );
  }

  Widget _apple(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: const Center(
        child: Text('🍎', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

// ── 2. MATHEMATICS: SUBTRACTION SIMULATOR ─────────────────────────────────────

class _SubtractionPlayground extends StatefulWidget {
  const _SubtractionPlayground();

  @override
  State<_SubtractionPlayground> createState() => _SubtractionPlaygroundState();
}

class _SubtractionPlaygroundState extends State<_SubtractionPlayground> {
  int _total = 8;
  int _takeAway = 3;
  bool _isPopped = false;

  void _pop() {
    setState(() {
      _isPopped = true;
    });
  }

  void _reset() {
    setState(() {
      _isPopped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interactive Subtraction', style: AppTextStyles.headlineSmall),
              IconButton(onPressed: _reset, icon: const Icon(Icons.refresh_rounded, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 12),

          if (!_isPopped) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _counterControl('Start Total', _total, (v) {
                  setState(() {
                    _total = v;
                    if (_takeAway >= _total) _takeAway = _total - 1;
                  });
                }),
                const Text('-', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.error)),
                _counterControl('Take Away', _takeAway, (v) => setState(() => _takeAway = v)),
              ],
            ),
            const SizedBox(height: 16),
          ],

          Container(
            padding: const EdgeInsets.all(16),
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(_total, (i) {
                  final isRemoved = i >= (_total - _takeAway);
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: (_isPopped && isRemoved) ? 0.25 : 1.0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (_isPopped && isRemoved) ? AppColors.grey200 : AppColors.success.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (_isPopped && isRemoved) ? AppColors.grey400 : AppColors.success,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (_isPopped && isRemoved) ? '💥' : '🎈',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_isPopped) ...[
            Text(
              '$_total - $_takeAway = ${_total - _takeAway}',
              style: AppTextStyles.displayMedium.copyWith(color: AppColors.success),
            ),
            const SizedBox(height: 4),
            const Text(
              'Remaining balloons counted! 🎈',
              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _pop,
                icon: const Icon(Icons.flash_on_rounded),
                label: Text('Pop $_takeAway Balloons!'),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _counterControl(String label, int val, ValueChanged<int> onChange) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Row(
          children: [
            IconButton(
              onPressed: val > 1 ? () => onChange(val - 1) : null,
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
            Text('$val', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: val < 10 ? () => onChange(val + 1) : null,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ],
        )
      ],
    );
  }
}

// ── 3. MATHEMATICS: MULTIPLICATION SIMULATOR ──────────────────────────────────

class _MultiplicationPlayground extends StatefulWidget {
  const _MultiplicationPlayground();

  @override
  State<_MultiplicationPlayground> createState() => _MultiplicationPlaygroundState();
}

class _MultiplicationPlaygroundState extends State<_MultiplicationPlayground> {
  int _rows = 3;
  int _cols = 4;
  int _highlightedIndex = -1;
  Timer? _timer;

  void _runCounter() {
    _timer?.cancel();
    setState(() => _highlightedIndex = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_highlightedIndex < (_rows * _cols) - 1) {
        setState(() => _highlightedIndex++);
      } else {
        timer.cancel();
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() => _highlightedIndex = -1);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interactive Multiplication', style: AppTextStyles.headlineSmall),
              IconButton(onPressed: _reset, icon: const Icon(Icons.refresh_rounded, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _counterControl('Rows', _rows, (v) {
                _reset();
                setState(() => _rows = v);
              }),
              const Text('×', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.secondary)),
              _counterControl('Columns', _cols, (v) {
                _reset();
                setState(() => _cols = v);
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Grid display
          Container(
            padding: const EdgeInsets.all(12),
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _cols,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: _rows * _cols,
              itemBuilder: (context, i) {
                final active = i <= _highlightedIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: active ? AppColors.secondary.withValues(alpha: 0.3) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: active ? AppColors.secondary : AppColors.grey200,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: active ? 1.0 : 0.2,
                      child: const Text(
                        '⭐',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '$_rows × $_cols = ${_rows * _cols}',
            style: AppTextStyles.displayMedium.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _runCounter,
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Animate Grid Count'),
            ),
          )
        ],
      ),
    );
  }

  Widget _counterControl(String label, int val, ValueChanged<int> onChange) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Row(
          children: [
            IconButton(
              onPressed: val > 1 ? () => onChange(val - 1) : null,
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
            Text('$val', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: val < 5 ? () => onChange(val + 1) : null,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ],
        )
      ],
    );
  }
}

// ── 4. SCIENCE: PHOTOSYNTHESIS PLAYGROUND ─────────────────────────────────────

class _PlantsPlayground extends StatefulWidget {
  const _PlantsPlayground();

  @override
  State<_PlantsPlayground> createState() => _PlantsPlaygroundState();
}

class _PlantsPlaygroundState extends State<_PlantsPlayground> {
  double _water = 0;
  double _sunlight = 0;
  double _air = 0;

  bool get _isGrown => _water >= 1.0 && _sunlight >= 1.0 && _air >= 1.0;

  void _reset() {
    setState(() {
      _water = 0;
      _sunlight = 0;
      _air = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interactive Photosynthesis', style: AppTextStyles.headlineSmall),
              IconButton(onPressed: _reset, icon: const Icon(Icons.refresh_rounded, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Supply Water, Sunlight and Air to perform Photosynthesis and grow the plant!',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Plant visual container
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Bubbles rising when grown
                if (_isGrown) ...[
                  const Positioned(top: 15, left: 60, child: Text('O₂ 🫧', style: TextStyle(fontSize: 16, color: Colors.blue))),
                  const Positioned(top: 30, right: 60, child: Text('O₂ 🫧', style: TextStyle(fontSize: 16, color: Colors.blue))),
                ],
                AnimatedScale(
                  scale: _isGrown ? 1.6 : (0.5 + (_water + _sunlight + _air) * 0.25),
                  duration: const Duration(milliseconds: 600),
                  child: Center(
                    child: Text(
                      _isGrown ? '🌻' : '🌱',
                      style: const TextStyle(fontSize: 52),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Interactive sliders/controls
          _resourceControl('💧 Supply Water', _water, (v) => setState(() => _water = v)),
          const SizedBox(height: 10),
          _resourceControl('☀️ Supply Sunlight', _sunlight, (v) => setState(() => _sunlight = v)),
          const SizedBox(height: 10),
          _resourceControl('💨 Supply Air (CO₂)', _air, (v) => setState(() => _air = v)),
          const SizedBox(height: 16),

          if (_isGrown) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Success! Photosynthesis generated Food (Glucose) and released Oxygen (O₂)!',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _resourceControl(String label, double progress, ValueChanged<double> onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            Text('${(progress * 100).toInt()}%', style: AppTextStyles.bodySmall),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: progress,
                min: 0,
                max: 1.0,
                activeColor: AppColors.success,
                inactiveColor: AppColors.grey200,
                onChanged: onChange,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_box_rounded, color: AppColors.success),
              onPressed: () => onChange(1.0),
            )
          ],
        )
      ],
    );
  }
}

// ── 5. SCIENCE: WATER CYCLE SIMULATOR ─────────────────────────────────────────

class _WaterCyclePlayground extends StatefulWidget {
  const _WaterCyclePlayground();

  @override
  State<_WaterCyclePlayground> createState() => _WaterCyclePlaygroundState();
}

class _WaterCyclePlaygroundState extends State<_WaterCyclePlayground> {
  String _activeStep = 'Tap on a process to begin...';
  String _emojiAnimation = '🌊';
  Color _themeColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text('Interactive Water Cycle', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),

          // Cycle Visual Sandbox
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7DD3FC)),
            ),
            child: Stack(
              children: [
                const Positioned(top: 10, left: 15, child: Text('☀️', style: TextStyle(fontSize: 32))),
                const Positioned(top: 20, right: 30, child: Text('☁️', style: TextStyle(fontSize: 38))),
                const Positioned(bottom: 10, left: 60, child: Text('🏔️', style: TextStyle(fontSize: 48))),
                const Positioned(bottom: 5, right: 15, child: Text('🌊', style: TextStyle(fontSize: 42))),

                // Active animated emoji
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _emojiAnimation,
                      key: ValueKey<String>(_emojiAnimation),
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Steps list
          Row(
            children: [
              Expanded(
                child: _cycleButton('Evaporation', '💧 ➜ 💨', () {
                  setState(() {
                    _activeStep = 'Evaporation: The Sun heats the ocean water, turning it into invisible water vapour rising into the air.';
                    _emojiAnimation = '💨';
                    _themeColor = AppColors.secondary;
                  });
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _cycleButton('Condensation', '💨 ➜ ☁️', () {
                  setState(() {
                    _activeStep = 'Condensation: High in the sky, the cold air turns the water vapour back into liquid water, forming clouds.';
                    _emojiAnimation = '☁️';
                    _themeColor = AppColors.primary;
                  });
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _cycleButton('Precipitation', '☁️ ➜ 🌧️', () {
                  setState(() {
                    _activeStep = 'Precipitation: When the clouds get too heavy with water, it falls back to the ground as rain or snow.';
                    _emojiAnimation = '🌧️';
                    _themeColor = AppColors.success;
                  });
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Narrative Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _themeColor),
            ),
            child: Text(
              _activeStep,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget _cycleButton(String label, String arrow, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.grey800,
        side: const BorderSide(color: AppColors.grey200),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(arrow, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
        ],
      ),
    );
  }
}

// ── 6. SCIENCE: DOMESTIC VS WILD ANIMALS PLAYGROUND ───────────────────────────

class _AnimalsPlayground extends StatefulWidget {
  const _AnimalsPlayground();

  @override
  State<_AnimalsPlayground> createState() => _AnimalsPlaygroundState();
}

class _AnimalsPlaygroundState extends State<_AnimalsPlayground> {
  final List<Map<String, dynamic>> _animals = [
    {'name': 'Cow 🐮', 'type': 'Domestic'},
    {'name': 'Lion 🦁', 'type': 'Wild'},
    {'name': 'Dog 🐶', 'type': 'Domestic'},
    {'name': 'Tiger 🐯', 'type': 'Wild'},
    {'name': 'Cat 🐱', 'type': 'Domestic'},
    {'name': 'Bear 🐻', 'type': 'Wild'},
  ];

  int _currentIndex = 0;
  String _message = 'Sort the animal into the correct home!';
  Color _messageColor = AppColors.grey600;

  void _classify(String selectedType) {
    final correctType = _animals[_currentIndex]['type'];
    if (selectedType == correctType) {
      setState(() {
        _message = 'Correct! The ${_animals[_currentIndex]['name']} is a $correctType animal! 🎉';
        _messageColor = AppColors.success;
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _animals.length;
            _message = 'Sort the animal into the correct home!';
            _messageColor = AppColors.grey600;
          });
        }
      });
    } else {
      setState(() {
        _message = 'Not quite! Try again.';
        _messageColor = AppColors.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final animal = _animals[_currentIndex];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text('Domestic vs Wild Animals', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),

          // Animal card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Center(
              child: Text(
                animal['name'],
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Choice Box
          Row(
            children: [
              Expanded(
                child: _classificationBtn(
                  '🏡 Domestic',
                  'Kept at homes/farms',
                  AppColors.success,
                  () => _classify('Domestic'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _classificationBtn(
                  '🌲 Wild',
                  'Lives in forests/jungle',
                  AppColors.warning,
                  () => _classify('Wild'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            _message,
            style: AppTextStyles.bodyMedium.copyWith(color: _messageColor, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _classificationBtn(String label, String sub, Color col, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: col,
        elevation: 2,
        side: BorderSide(color: col.withValues(alpha: 0.5), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onTap,
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 10, color: AppColors.grey600)),
        ],
      ),
    );
  }
}

// ── 7. ENGLISH: NOUN IDENTIFICATION PLAYGROUND ────────────────────────────────

class _EnglishNounsPlayground extends StatefulWidget {
  const _EnglishNounsPlayground();

  @override
  State<_EnglishNounsPlayground> createState() => _EnglishNounsPlaygroundState();
}

class _EnglishNounsPlaygroundState extends State<_EnglishNounsPlayground> {
  final List<String> _words = ['The', 'dog', 'runs', 'swiftly', 'to', 'the', 'park'];
  final Set<int> _nounIndices = {1, 6}; // dog, park
  final Set<int> _selectedIndices = {};
  bool _validated = false;
  bool _isSuccess = false;

  void _toggleWord(int index) {
    if (_validated) return;
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _check() {
    setState(() {
      _validated = true;
      _isSuccess = _selectedIndices.containsAll(_nounIndices) && _selectedIndices.length == _nounIndices.length;
    });
  }

  void _reset() {
    setState(() {
      _selectedIndices.clear();
      _validated = false;
      _isSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Find Nouns (Naming Words)', style: AppTextStyles.headlineSmall),
              IconButton(onPressed: _reset, icon: const Icon(Icons.refresh_rounded, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Tap all the naming words (Nouns) in the sentence below:', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 20),

          // Word Board
          Wrap(
            spacing: 6,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(_words.length, (i) {
              final isSelected = _selectedIndices.contains(i);
              final isN = _nounIndices.contains(i);
              Color btnColor = Colors.white;
              Color borderCol = AppColors.grey200;
              Color textCol = AppColors.grey800;

              if (isSelected) {
                btnColor = AppColors.primary.withValues(alpha: 0.15);
                borderCol = AppColors.primary;
                textCol = AppColors.primary;
              }

              if (_validated) {
                if (isN) {
                  btnColor = const Color(0xFFD1FAE5);
                  borderCol = AppColors.success;
                  textCol = AppColors.success;
                } else if (isSelected) {
                  btnColor = const Color(0xFFFEE2E2);
                  borderCol = AppColors.error;
                  textCol = AppColors.error;
                }
              }

              return InkWell(
                onTap: () => _toggleWord(i),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderCol, width: 1.5),
                  ),
                  child: Text(
                    _words[i],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textCol),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          if (_validated) ...[
            Text(
              _isSuccess ? 'Correct! "dog" and "park" are naming words (nouns). 🎉' : 'Incorrect, try again! Remember: nouns name a thing or place.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _isSuccess ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _check,
                child: const Text('Check Answers'),
              ),
            )
          ]
        ],
      ),
    );
  }
}

// ── 8. ENGLISH: VERB IDENTIFICATION PLAYGROUND ────────────────────────────────

class _EnglishVerbsPlayground extends StatefulWidget {
  const _EnglishVerbsPlayground();

  @override
  State<_EnglishVerbsPlayground> createState() => _EnglishVerbsPlaygroundState();
}

class _EnglishVerbsPlaygroundState extends State<_EnglishVerbsPlayground> {
  final List<String> _words = ['She', 'plays', 'and', 'sings', 'happily', 'every', 'day'];
  final Set<int> _verbIndices = {1, 3}; // plays, sings
  final Set<int> _selectedIndices = {};
  bool _validated = false;
  bool _isSuccess = false;

  void _toggleWord(int index) {
    if (_validated) return;
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _check() {
    setState(() {
      _validated = true;
      _isSuccess = _selectedIndices.containsAll(_verbIndices) && _selectedIndices.length == _verbIndices.length;
    });
  }

  void _reset() {
    setState(() {
      _selectedIndices.clear();
      _validated = false;
      _isSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Find Verbs (Action Words)', style: AppTextStyles.headlineSmall),
              IconButton(onPressed: _reset, icon: const Icon(Icons.refresh_rounded, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Tap all the action words (Verbs) in the sentence below:', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 20),

          // Word Board
          Wrap(
            spacing: 6,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(_words.length, (i) {
              final isSelected = _selectedIndices.contains(i);
              final isV = _verbIndices.contains(i);
              Color btnColor = Colors.white;
              Color borderCol = AppColors.grey200;
              Color textCol = AppColors.grey800;

              if (isSelected) {
                btnColor = AppColors.secondary.withValues(alpha: 0.15);
                borderCol = AppColors.secondary;
                textCol = AppColors.secondary;
              }

              if (_validated) {
                if (isV) {
                  btnColor = const Color(0xFFD1FAE5);
                  borderCol = AppColors.success;
                  textCol = AppColors.success;
                } else if (isSelected) {
                  btnColor = const Color(0xFFFEE2E2);
                  borderCol = AppColors.error;
                  textCol = AppColors.error;
                }
              }

              return InkWell(
                onTap: () => _toggleWord(i),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderCol, width: 1.5),
                  ),
                  child: Text(
                    _words[i],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textCol),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          if (_validated) ...[
            Text(
              _isSuccess ? 'Correct! "plays" and "sings" are actions (verbs). 🎉' : 'Incorrect, try again! Verbs tell us what someone is doing.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _isSuccess ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _check,
                child: const Text('Check Answers'),
              ),
            )
          ]
        ],
      ),
    );
  }
}

// ── 9. HISTORY: ANCIENT INDIA TIMELINE ────────────────────────────────────────

class _HistoryAncientPlayground extends StatefulWidget {
  const _HistoryAncientPlayground();

  @override
  State<_HistoryAncientPlayground> createState() => _HistoryAncientPlaygroundState();
}

class _HistoryAncientPlaygroundState extends State<_HistoryAncientPlayground> {
  final List<Map<String, String>> _nodes = [
    {
      'period': 'Indus Valley',
      'dates': '2500 BCE',
      'detail': 'Harappa and Mohenjo-daro cities built with great street planning and water drains.'
    },
    {
      'period': 'Vedic Period',
      'dates': '1500 BCE',
      'detail': 'Vedas are composed; rural kingdoms and culture establish across northern plains.'
    },
    {
      'period': 'Maurya Empire',
      'dates': '322 BCE',
      'detail': 'Emperor Ashoka rules, spreading peace, Buddhist dharma messages, and carving stone pillars.'
    },
    {
      'period': 'Gupta Golden Age',
      'dates': '319 CE',
      'detail': 'Great discoveries made in Indian science, math, art, literature, and astronomy.'
    },
  ];

  int _selectedNode = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.badgePurple.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.badgePurple.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text('Ancient India Interactive Timeline', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),

          // Nodes selectors
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_nodes.length, (i) {
                final isSelected = _selectedNode == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedNode = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.badgePurple : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.badgePurple : AppColors.grey200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _nodes[i]['dates']!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white70 : AppColors.grey600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _nodes[i]['period']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected ? Colors.white : AppColors.grey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Detail Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.badgePurple.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.badgePurple.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🏛️', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      _nodes[_selectedNode]['period']!,
                      style: AppTextStyles.headlineSmall.copyWith(color: AppColors.badgePurple),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _nodes[_selectedNode]['detail']!,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ── 10. HISTORY: INDEPENDENCE TIMELINE ────────────────────────────────────────

class _HistoryIndependencePlayground extends StatefulWidget {
  const _HistoryIndependencePlayground();

  @override
  State<_HistoryIndependencePlayground> createState() => _HistoryIndependencePlaygroundState();
}

class _HistoryIndependencePlaygroundState extends State<_HistoryIndependencePlayground> {
  final List<Map<String, String>> _events = [
    {
      'year': '1857',
      'title': 'The First Revolt',
      'desc': 'Mangal Pandey and Indian soldiers lead the first major nationwide uprising against East India Company rule.'
    },
    {
      'year': '1930',
      'title': 'Salt Satyagraha',
      'desc': 'Mahatma Gandhi marches 240 miles to Dandi to break the salt law, launching the civil disobedience movement.'
    },
    {
      'year': '1942',
      'title': 'Quit India Movement',
      'desc': 'Gandhi delivers the famous "Do or Die" speech calling for an immediate end to British rule.'
    },
    {
      'year': '1947',
      'title': 'Independence! 🇮🇳',
      'desc': 'India gains freedom on August 15, starting a new democratic journey as an independent nation.'
    },
  ];

  int _selectedEvent = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text('Independence struggle Timeline', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),

          // Events selector list
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_events.length, (i) {
                final isSelected = _selectedEvent == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEvent = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.warning : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.warning : AppColors.grey200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _events[i]['year']!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white70 : AppColors.grey600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _events[i]['title']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected ? Colors.white : AppColors.grey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Detail Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('✊', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      _events[_selectedEvent]['title']!,
                      style: AppTextStyles.headlineSmall.copyWith(color: AppColors.warning),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _events[_selectedEvent]['desc']!,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
