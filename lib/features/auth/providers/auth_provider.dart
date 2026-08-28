import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';
import '../data/models/auth_user.dart';

/// Provides the [AuthService] singleton.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Streams the current authentication state.
/// Emits null when signed out, [AuthUser] when signed in.
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// State notifier for authentication operations.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthNotifier(this._authService)
      : super(const AsyncValue.data(null)) {
    // Initialize with current user if any
    state = AsyncValue.data(_authService.currentUser);
  }

  final AuthService _authService;

  /// Sign up a new user with email, password, and display name.
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AsyncValue.data(user);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(
        _getErrorMessage(e),
        StackTrace.current,
      );
    } catch (e) {
      state = AsyncValue.error(
        e.toString(),
        StackTrace.current,
      );
    }
  }

  /// Sign in an existing user with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(
        _getErrorMessage(e),
        StackTrace.current,
      );
    } catch (e) {
      state = AsyncValue.error(
        e.toString(),
        StackTrace.current,
      );
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(
        e.toString(),
        StackTrace.current,
      );
    }
  }

  /// Send a password reset email.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      state = AsyncValue.error(
        e.toString(),
        StackTrace.current,
      );
      rethrow;
    }
  }

  /// Convert Firebase error codes to user-friendly messages.
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later.';
      case 'operation-not-allowed':
        return 'Sign in with email is not enabled.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
