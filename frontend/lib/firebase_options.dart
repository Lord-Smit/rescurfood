// File generated for local/dev builds. Replace via `flutterfire configure`
// when you have a real Firebase project.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'run `flutterfire configure` with a real Firebase project.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'run `flutterfire configure` with a real Firebase project.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAmNqv4o1Yt2I8Bc6AU8fIE-3JhVoN8SI',
    appId: '1:480115541957:web:be8e6194ac4c48b8e4edac',
    messagingSenderId: '480115541957',
    projectId: 'foodlink-007',
    authDomain: 'foodlink-007.firebaseapp.com',
    storageBucket: 'foodlink-007.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAmNqv4o1Yt2I8Bc6AU8fIE-3JhVoN8SI',
    appId: '1:480115541957:android:be8e6194ac4c48b8e4edac',
    messagingSenderId: '480115541957',
    projectId: 'foodlink-007',
    storageBucket: 'foodlink-007.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAmNqv4o1Yt2I8Bc6AU8fIE-3JhVoN8SI',
    appId: '1:480115541957:ios:be8e6194ac4c48b8e4edac',
    messagingSenderId: '480115541957',
    projectId: 'foodlink-007',
    storageBucket: 'foodlink-007.firebasestorage.app',
    iosBundleId: 'com.example.foodlink',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBAmNqv4o1Yt2I8Bc6AU8fIE-3JhVoN8SI',
    appId: '1:480115541957:ios:be8e6194ac4c48b8e4edac',
    messagingSenderId: '480115541957',
    projectId: 'foodlink-007',
    storageBucket: 'foodlink-007.firebasestorage.app',
    iosBundleId: 'com.example.foodlink',
  );
}
