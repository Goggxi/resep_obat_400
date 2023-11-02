// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyAfshdEICukItOEuFqJLbjlGW-Iuy8iTJQ',
    appId: '1:794740633526:web:dd98993dabb72ea8f69b17',
    messagingSenderId: '794740633526',
    projectId: 'goggxi-project-42b54',
    authDomain: 'goggxi-project-42b54.firebaseapp.com',
    storageBucket: 'goggxi-project-42b54.appspot.com',
    measurementId: 'G-FMLTGM19WM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmyQEWcl5CS_qiGq3kn6gBp8rLiNaG-Pw',
    appId: '1:794740633526:android:6ccc2e15951d9feef69b17',
    messagingSenderId: '794740633526',
    projectId: 'goggxi-project-42b54',
    storageBucket: 'goggxi-project-42b54.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDsj-shYsG4Vf-Te-om6G-jbA81oNw8FOc',
    appId: '1:794740633526:ios:71f12925dbb0f40af69b17',
    messagingSenderId: '794740633526',
    projectId: 'goggxi-project-42b54',
    storageBucket: 'goggxi-project-42b54.appspot.com',
    iosBundleId: 'com.goggxi.resepObat400',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDsj-shYsG4Vf-Te-om6G-jbA81oNw8FOc',
    appId: '1:794740633526:ios:844332e91dbfae88f69b17',
    messagingSenderId: '794740633526',
    projectId: 'goggxi-project-42b54',
    storageBucket: 'goggxi-project-42b54.appspot.com',
    iosBundleId: 'com.goggxi.resepObat400.RunnerTests',
  );
}