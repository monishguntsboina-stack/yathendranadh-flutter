// FlutterFire configuration template
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDZYKnflT6ssAcAoeu4dIMcf3Z8qG1xuyU',
    appId: '1:918855797228:web:21a2715c50de27f22798c9',
    messagingSenderId: '918855797228',
    projectId: 'planning-with-ai-972d8',
    authDomain: 'planning-with-ai-972d8.firebaseapp.com',
    storageBucket: 'planning-with-ai-972d8.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_JJlWeLhj9-a-rCCNs2dyHCaFTdQU6Hs',
    appId: '1:918855797228:android:afdc8d05aa9b87432798c9',
    messagingSenderId: '918855797228',
    projectId: 'planning-with-ai-972d8',
    storageBucket: 'planning-with-ai-972d8.firebasestorage.app',
  );
}
