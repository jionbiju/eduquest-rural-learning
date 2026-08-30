import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../home/providers/home_provider.dart';
import '../../data/models/auth_user.dart';
import '../../providers/auth_provider.dart';

/// Sign up screen for new users.
/// Collects email, password, and display name.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _groupIdController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedLanguage = 'en';
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _groupIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Get groupId (required for both students and teachers)
    final groupId = _groupIdController.text.trim();
    if (groupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a class/group ID')),
      );
      return;
    }

    // Sign up via Firebase with role and groupId
    await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
          role: _selectedRole,
          groupId: groupId,
        );

    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);
    authState.whenData((user) {
      if (user != null) {
        if (user.role == UserRole.student) {
          // Create student profile
          ref.read(studentProfileProvider.notifier).createProfile(
                name: user.displayName,
                studentId: user.uid,
                language: _selectedLanguage,
                groupId: groupId,
              );

          if (mounted) context.goNamed('home');
        } else {
          // Teacher - go to teacher dashboard
          if (mounted) context.goNamed('teacher_dashboard');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero section ─────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.secondary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('✨', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Join EduQuest',
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Start your learning journey',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Display Name ─────────────────────────────────────
                Text('Full Name', style: AppTextStyles.labelLarge),
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

                // ── Role Selector ────────────────────────────────────
                Text('I am a...', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _RoleButton(
                      icon: Icons.school_rounded,
                      label: 'Student',
                      role: UserRole.student,
                      selected: _selectedRole == UserRole.student,
                      onTap: () => setState(() => _selectedRole = UserRole.student),
                    ),
                    const SizedBox(width: 12),
                    _RoleButton(
                      icon: Icons.person_rounded,
                      label: 'Teacher',
                      role: UserRole.teacher,
                      selected: _selectedRole == UserRole.teacher,
                      onTap: () => setState(() => _selectedRole = UserRole.teacher),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Group ID field ───────────────────────────────────
                Text(
                  _selectedRole == UserRole.teacher 
                      ? 'Class/Group ID (you teach)'
                      : 'Class/Group ID',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _groupIdController,
                  decoration: InputDecoration(
                    hintText: 'e.g. village_01, class_5a',
                    prefixIcon: const Icon(Icons.group_outlined),
                    helperText: _selectedRole == UserRole.teacher
                        ? 'Students in this group will see your lessons'
                        : 'Ask your teacher for the group ID',
                    helperMaxLines: 2,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your group ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Email field ──────────────────────────────────────
                Text('Email Address', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'your@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!v.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Password field ───────────────────────────────────
                Text('Password', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Confirm Password field ───────────────────────────
                Text('Confirm Password', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Re-enter password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmPassword =
                            !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm password';
                    }
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
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
                const SizedBox(height: 32),

                // ── Error message ────────────────────────────────────
                authState.maybeWhen(
                  error: (error, stack) => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Text(
                          error.toString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (error.toString().contains('CONFIGURATION_NOT_FOUND') ||
                          error.toString().contains('operation-not-allowed'))
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚠️ Firebase Setup Required',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Enable Email/Password auth in Firebase Console:\n'
                                '1. Go to Firebase Console\n'
                                '2. Select "eduquest-5483a" project\n'
                                '3. Authentication > Sign-in method\n'
                                '4. Enable "Email/Password"',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),

                // ── Submit button ────────────────────────────────────
                PrimaryButton(
                  label: 'Create Account',
                  icon: Icons.person_add_rounded,
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),

                // ── Sign in link ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
                ? AppColors.secondary.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.grey200,
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
                      ? AppColors.secondary
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

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.icon,
    required this.label,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final UserRole role;
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
              Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.grey600,
                size: 22,
              ),
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
