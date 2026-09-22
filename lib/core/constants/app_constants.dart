class AppConstants {
  AppConstants._();

  static const String appName = 'TaskFlow Pro';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyDefaultNotificationMinutes = 'default_notif_minutes';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyHapticsEnabled = 'haptics_enabled';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyDefaultListId = 'default_list_id';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String listsCollection = 'lists';

  // Defaults
  static const int defaultNotificationLeadMinutes = 15;
}
