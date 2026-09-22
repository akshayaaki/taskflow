import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/network/firebase_config.dart';
import 'core/services/notification_service.dart';
import 'data/local/isar_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/lists/providers/lists_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage (SharedPreferences & Isar DB)
  final prefs = await SharedPreferences.getInstance();
  final isarService = await IsarService.getInstance();

  // Initialize Firebase (safely handles offline/unconfigured environments)
  await FirebaseConfig.initialize();

  // Initialize Local Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        isarServiceProvider.overrideWithValue(isarService),
      ],
      child: const TaskFlowApp(),
    ),
  );
}
