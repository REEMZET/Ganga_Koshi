// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAG4nUVRE4vZ9k7VvdzT8owFYhVSHixrK4',
    appId: '1:270305996839:web:41f7496efc13959e5fde02',
    messagingSenderId: '270305996839',
    projectId: 'ganga-koshi-e4noc3',
    authDomain: 'ganga-koshi-e4noc3.firebaseapp.com',
    databaseURL: 'https://ganga-koshi-e4noc3-default-rtdb.firebaseio.com',
    storageBucket: 'ganga-koshi-e4noc3.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCoJ_z-v0b3-WsciwyPzG6e7020aVnPWHg',
    appId: '1:270305996839:android:5482e3659857d1cc5fde02',
    messagingSenderId: '270305996839',
    projectId: 'ganga-koshi-e4noc3',
    databaseURL: 'https://ganga-koshi-e4noc3-default-rtdb.firebaseio.com',
    storageBucket: 'ganga-koshi-e4noc3.appspot.com',
  );
}