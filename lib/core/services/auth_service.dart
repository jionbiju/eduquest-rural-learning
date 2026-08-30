import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/data/models/auth_user.dart';

/// Wrapper around Firebase Authentication.
/// Handles sign up, login, logout, and password reset.
/// Falls back to mock auth if Firebase is not initialized.
class AuthService {
  final _auth = FirebaseAuth.instance;
  static bool _isFirebaseReady = false;

  /// Check if Firebase is properly initialized
  static Future<bool> checkFirebaseReady() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseReady = true;
      }
    } catch (_) {
      _isFirebaseReady = false;
    }
    return _isFirebaseReady;
  }

  /// Returns the currently signed-in user, or null if not authenticated.
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Returns true if a user is currently signed in.
  bool get isSignedIn => _auth.currentUser != null;

  /// Listens to authentication state changes.
  /// Emits null when signed out, AuthUser when signed in.
  Stream<AuthUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AuthUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    });
  }

  /// Creates a new user account with email and password.
  /// Throws [FirebaseAuthException] on failure.
  /// Returns the newly created [AuthUser].
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.student,
    String? groupId,
  }) async {
    try {
      debugPrint('📝 Signing up user: $email with role: ${role.name}');
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Sign up returned null user');

      // Update display name
      await user.updateDisplayName(displayName);
      await user.reload();

      debugPrint('✅ Sign up successful for: $email');
      return AuthUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? displayName,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        role: role,
        groupId: groupId,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign up failed: ${e.code} - ${e.message}');
      // Re-throw with more helpful message
      if (e.code == 'operation-not-allowed') {
        throw FirebaseAuthException(
          code: e.code,
          message: 'Email/Password sign up is not enabled in Firebase Console. '
              'Go to Firebase Console > Authentication > Sign-in method > enable Email/Password',
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ Sign up failed: $e');
      rethrow;
    }
  }

  /// Signs in an existing user with email and password.
  /// Throws [FirebaseAuthException] on failure.
  /// Returns the signed-in [AuthUser].
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Signing in user: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Sign in returned null user');

      debugPrint('✅ Sign in successful for: $email');
      return AuthUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign in failed: ${e.code} - ${e.message}');
      // Re-throw with more helpful message
      if (e.code == 'operation-not-allowed') {
        throw FirebaseAuthException(
          code: e.code,
          message: 'Email/Password sign in is not enabled in Firebase Console. '
              'Go to Firebase Console > Authentication > Sign-in method > enable Email/Password',
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ Sign in failed: $e');
      rethrow;
    }
  }

  /// Signs out the currently signed-in user.
  Future<void> signOut() async {
    try {
      debugPrint('🚪 Signing out user');
      await _auth.signOut();
      debugPrint('✅ Sign out successful');
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
      rethrow;
    }
  }

  /// Sends a password reset email to the given email address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('📧 Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent');
    } catch (e) {
      debugPrint('❌ Password reset failed: $e');
      rethrow;
    }
  }

  /// Updates the current user's display name.
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');
      await user.updateDisplayName(displayName);
      await user.reload();
      debugPrint('✅ Display name updated: $displayName');
    } catch (e) {
      debugPrint('❌ Update display name failed: $e');
      rethrow;
    }
  }

  /// Updates the current user's profile picture URL.
  Future<void> updatePhotoUrl(String photoUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');
      await user.updatePhotoURL(photoUrl);
      await user.reload();
      debugPrint('✅ Photo URL updated');
    } catch (e) {
      debugPrint('❌ Update photo URL failed: $e');
      rethrow;
    }
  }

  /// Deletes the current user's account.
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');
      await user.delete();
      debugPrint('✅ Account deleted');
    } catch (e) {
      debugPrint('❌ Delete account failed: $e');
      rethrow;
    }
  }
}
