import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase/FCM must never block the first frame — stub configs hang otherwise.
  await _initializeFirebase();
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: FoodBridgeApp(),
    ),
  );
}

Future<void> _initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) return;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 8));
  } catch (e, st) {
    debugPrint('Firebase init skipped: $e\n$st');
  }
}
