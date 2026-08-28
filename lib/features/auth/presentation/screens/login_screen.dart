import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../home/providers/home_provider.dart';

/// First-launch login screen.
/// Collects student name and ID, saves to local storage.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  String _selectedLanguage = 'en';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await ref.read(studentProfileProvider.notifier).createProfile(
          name: _nameController.text.trim(),
          studentId: _idController.text.trim(),
          language: _selectedLanguage,
        );

    if (mounted) context.goNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // ── Hero section ─────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🎓', style: TextStyle(fontSize: 46)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Welcome to EduQuest',
                          style: AppTextStyles.displayMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Learn. Play. Grow.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // ── Name field ───────────────────────────────────────
                Text('Your Name', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Priya Sharma',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Student ID field ─────────────────────────────────
                Text('Student ID', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. STU001',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your student ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Language picker ──────────────────────────────────
                Text('Language / भाषा', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _LangButton(
                      flag: '🇬🇧',
                      label: 'English',
                      code: 'en',
                      selected: _selectedLanguage == 'en',
                      onTap: () =>
                          setState(() => _selectedLanguage = 'en'),
                    ),
                    const SizedBox(width: 12),
                    _LangButton(
                      flag: '🇮🇳',
                      label: 'हिन्दी',
                      code: 'hi',
                      selected: _selectedLanguage == 'hi',
                      onTap: () =>
                          setState(() => _selectedLanguage = 'hi'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // ── Submit ───────────────────────────────────────────
                PrimaryButton(
                  label: 'Start Learning',
                  icon: Icons.rocket_launch_rounded,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({
    required this.flag,
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.grey200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: selected
                      ? AppColors.primary
                      : AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
