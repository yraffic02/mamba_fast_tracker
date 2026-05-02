import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_init;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _notifications;

  NotificationService._internal() {
    _notifications = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize() async {
    tz_init.initializeTimeZones();
    final location = tz.getLocation('America/Sao_Paulo');
    tz.setLocalLocation(location);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    print('NotificationService: initialized with timezone');
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'mamba_fast_tracker',
      'Mamba Fast Tracker',
      channelDescription: 'Notifications for fasting tracker',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
    print('Notification sent: $title');
  }

  Future<void> scheduleDailyNotification({
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    // Cancel previous notifications with same title to avoid duplicates
    await _notifications.cancelAll();

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // If time already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    const androidDetails = AndroidNotificationDetails(
      'mamba_fast_tracker',
      'Mamba Fast Tracker',
      channelDescription: 'Notifications for fasting tracker',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      DateTime.now().millisecond,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    print('Daily notification scheduled: $title at $hour:${minute.toString().padLeft(2, '0')} (${tzScheduledDate.toIso8601String()})');
  }

  Future<void> scheduleOneTimeNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    const androidDetails = AndroidNotificationDetails(
      'mamba_fast_tracker',
      'Mamba Fast Tracker',
      channelDescription: 'Notifications for fasting tracker',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      DateTime.now().millisecond,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    print('One-time notification scheduled: $title at ${tzScheduledDate.toIso8601String()})');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('All notifications cancelled');
  }

  Future<void> notifyFastingStarted() async {
    await showNotification(
      'Jejum Iniciado',
      'Seu jejum começou. Boa sorte!',
    );
  }

  Future<void> notifyFastingEnded() async {
    await showNotification(
      'Jejum Concluído',
      'Parabéns! Você completou seu jejum.',
    );
  }

  Future<void> notifyFastingGoalReached() async {
    await showNotification(
      'Meta Atingida!',
      'Parabéns! Você atingiu sua meta de jejum.',
    );
  }
}
