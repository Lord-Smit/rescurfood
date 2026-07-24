import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Keep lightweight — app may not be fully initialized here.
  debugPrint('Background message: ${message.messageId}');
}

class NotificationService {
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      debugPrint('NotificationService: Firebase not ready — skipping FCM');
      return;
    }

    final messaging = FirebaseMessaging.instance;

    try {
      await messaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
          )
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('NotificationService: permission request failed: $e');
    }

    try {
      final token = await messaging
          .getToken()
          .timeout(const Duration(seconds: 5));
      if (token != null) {
        _sendTokenToServer(token);
      }
    } catch (e) {
      debugPrint('NotificationService: getToken() failed: $e');
    }

    try {
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('NotificationService: listener setup failed: $e');
    }
  }

  void _sendTokenToServer(String token) {
    // TODO: send FCM token to backend
    debugPrint('FCM token: $token');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // TODO: show local notification or in-app banner
    debugPrint('Foreground message: ${message.messageId}');
  }
}
