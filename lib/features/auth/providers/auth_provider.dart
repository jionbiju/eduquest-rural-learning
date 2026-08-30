import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../data/models/auth_user.dart';

/// Provides the [AuthService] singleton.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provides the [FirestoreService] singleton.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Streams the current authentication state.
/// Emits null when signed out, [AuthUser] when signed in.
final authStateProvider = StreamProvider<AuthUser?>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  await for (final user in authService.authStateChanges) {
    if (user == null) {
      yield null;
    } else {
      // Fetch full profile from Firestore including role and groupId
      final profile = await firestoreService.getUserProfile(user.uid);
      yield profile ?? user;
    }
  }
});

/// State notifier for authentication operations.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthNotifier(this._authService, this._firestoreService)
      : super(const AsyncValue.data(null)) {
    // Initialize with current user if any
    _initializeUser();
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<void> _initializeUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      // Fetch full profile from Firestore
      final profile = await _firestoreService.getUserProfile(user.uid);
      state = AsyncValue.data(profile ?? user);
    }
  }

  /// Sign up a new user with email, password, display name, role, and groupId.
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.student,
    String? groupId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        groupId: groupId,
      );
      
      // Save user profile to Firestore
      await _firestoreService.saveUserProfile(user);
      
      // Store auth user in Hive for router access
      await _storeAuthUser(user);
      
      debugPrint('✅ Auth user stored in Hive with role: ${user.role.name}');
      
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
      
      // Fetch full profile from Firestore
      final profile = await _firestoreService.getUserProfile(user.uid);
      final authUser = profile ?? user;
      
      // Store auth user in Hive for router access
      await _storeAuthUser(authUser);
      
      debugPrint('✅ Auth user stored in Hive with role: ${authUser.role.name}');
      
      state = AsyncValue.data(authUser);
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

  /// Store AuthUser in Hive for router access
  Future<void> _storeAuthUser(AuthUser user) async {
    try {
      final box = Hive.box<String>(AppConstants.hiveUserBox);
      await box.put('authUser', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('❌ Failed to store auth user in Hive: $e');
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      
      // Clear auth user from Hive
      final box = Hive.box<String>(AppConstants.hiveUserBox);
      await box.delete('authUser');
      
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
