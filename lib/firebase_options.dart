import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzCxoP74vhWsh9kBwxhO-mdQ6ZZP-XWho',
    appId: '1:716695427404:android:33716a21a9c21de45d57e9',
    messagingSenderId: '716695427404',
    projectId: 'p2smpl',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    authDomain: 'your-web-auth-domain',
    projectId: 'p2smpl',
    storageBucket: 'your-web-storage-bucket',
    messagingSenderId: 'your-web-messaging-id',
    appId: 'your-web-app-id',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-ios-messaging-id',
    projectId: 'p2smpl',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-windows-api-key',
    appId: 'your-windows-app-id',
    messagingSenderId: 'your-windows-messaging-id',
    projectId: 'p2smpl',
  );
}
