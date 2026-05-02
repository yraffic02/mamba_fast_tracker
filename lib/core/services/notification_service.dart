import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'mamba_fast_tracker',
          'Mamba Fast Tracker',
          description: 'Notificações do Mamba Fast Tracker',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ));
  }

  Future<bool> requestNotificationPermissions() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final notifPermission = await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
      return notifPermission ?? false;
    }
    return true;
  }

  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'mamba_fast_tracker',
      'Mamba Fast Tracker',
      channelDescription: 'Notificações do Mamba Fast Tracker',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _flutterLocalNotificationsPlugin.show(0, title, body, details);
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final scheduled = _nextInstanceOfTime(hour, minute);
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'mamba_fast_tracker',
          'Mamba Fast Tracker',
          channelDescription: 'Notificações do Mamba Fast Tracker',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleOneTimeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'mamba_fast_tracker',
          'Mamba Fast Tracker',
          channelDescription: 'Notificações do Mamba Fast Tracker',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> notifyFastingStarted() async {
    await showNotification('Jejum Iniciado', 'Seu jejum começou. Boa sorte!');
  }

  Future<void> notifyFastingEnded() async {
    await showNotification('Jejum Concluído', 'Parabéns! Você completou seu jejum.');
  }

  Future<void> notifyFastingGoalReached() async {
    await showNotification('Meta Atingida!', 'Parabéns! Você atingiu sua meta de jejum.');
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
