// PLACEHOLDER. Replace this file by running, from the project folder:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Pick the same Firebase project the web dashboard uses. Until then the app
// starts in local demo mode (nothing is sent to a server).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Run `flutterfire configure` to add this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBpthPp7keyP8I9AvP9hxDil6-bPATIrJY',
    appId: '1:29979317148:android:5e9bd1214440aa34782e59',
    messagingSenderId: '29979317148',
    projectId: 'fold-flow',
    storageBucket: 'fold-flow.firebasestorage.app',
  );
}
