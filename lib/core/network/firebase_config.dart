import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<bool> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return true;
      }
      await Firebase.initializeApp();
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint(
        'FirebaseConfig: Firebase not initialized or config missing. Running in local-first mode. ($e)',
      );
      _isInitialized = false;
      return false;
    }
  }
}
