import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (e) {
      debugPrint('NotificationService: Could not configure timezone: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked with payload: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

    final iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  int _notificationIdFromTaskId(String taskId) {
    return taskId.hashCode.abs() % 2147483647;
  }

  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (scheduledDate.isBefore(DateTime.now())) {
      return; // Do not schedule in the past
    }

    final id = _notificationIdFromTaskId(taskId);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_reminders_channel',
      'Task Reminders',
      channelDescription: 'Notifications for upcoming and due tasks',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime tzScheduled =
        tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body.isEmpty ? 'Task is due now' : body,
        tzScheduled,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: taskId,
      );
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  Future<void> cancelTaskReminder(String taskId) async {
    if (!_isInitialized) return;
    final id = _notificationIdFromTaskId(taskId);
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!_isInitialized) return;
    await _notificationsPlugin.cancelAll();
  }
}
