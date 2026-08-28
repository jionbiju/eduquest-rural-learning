import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

/// Handles Firebase initialisation.
/// Safe to call multiple times — returns early if already initialised.
class FirebaseService {
  static bool _initialised = false;

  static Future<void> init() async {
    if (_initialised) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialised = true;
      debugPrint('✅ Firebase initialised');
    } catch (e) {
      // Firebase init will fail if placeholder credentials are used.
      // App continues in offline-only mode.
      debugPrint('⚠️  Firebase init skipped (offline mode): $e');
    }
  }

  static bool get isInitialised => _initialised;
}
