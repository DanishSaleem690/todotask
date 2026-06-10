// Firebase configuration for project: todos-firestore-945ed
// Generated from android/app/google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the current platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured. Add a Web app in Firebase Console '
        'and run flutterfire configure --platforms=web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for Android.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3__U74Q1Z-fOMBhYxijzIf_focaF9Lu4',
    appId: '1:960070611808:android:21f11a4220fbbafb6ea405',
    messagingSenderId: '960070611808',
    projectId: 'todos-firestore-945ed',
    storageBucket: 'todos-firestore-945ed.firebasestorage.app',
  );
}
