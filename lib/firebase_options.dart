import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase config for the web target only — multiplayer is web-only, native
/// builds (android/ios/desktop) never call Firebase.initializeApp().
/// Debug builds (`flutter run`) hit the `dev` project so schema/rules
/// iteration never touches live rooms; release builds (what CI deploys to
/// GitHub Pages) hit `prod`.
class DefaultFirebaseOptions {
  static FirebaseOptions get web => kDebugMode ? _dev : _prod;

  static const _prod = FirebaseOptions(
    apiKey: 'AIzaSyAa0y2O_O_QP4HZfrmUr_Yr75cAnw1N2rU',
    appId: '1:560456125451:web:2963368b85bceceb7b0b0e',
    messagingSenderId: '560456125451',
    projectId: 'shotgame-acd8e',
    authDomain: 'shotgame-acd8e.firebaseapp.com',
    databaseURL:
        'https://shotgame-acd8e-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'shotgame-acd8e.firebasestorage.app',
    measurementId: 'G-11LLW0RS8F',
  );

  static const _dev = FirebaseOptions(
    apiKey: 'AIzaSyAohzva3LAfmq9_ptCjFJSBDB7Og3UpuJc',
    appId: '1:650557488248:web:2f776600645daba1a7c18d',
    messagingSenderId: '650557488248',
    projectId: 'shot-oyunu-dev',
    authDomain: 'shot-oyunu-dev.firebaseapp.com',
    databaseURL:
        'https://shot-oyunu-dev-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'shot-oyunu-dev.firebasestorage.app',
  );
}
