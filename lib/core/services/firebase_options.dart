import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Firebase configuration auto-populated from google-services.json
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4TdO5W7pq6iT6hMaJXLolQFy9poVMtJc',
    appId: '1:906387639454:android:d622443cc944a4aa0eff8f',
    messagingSenderId: '906387639454',
    projectId: 'eduquest-5483a',
    storageBucket: 'eduquest-5483a.firebasestorage.app',
  );
}
