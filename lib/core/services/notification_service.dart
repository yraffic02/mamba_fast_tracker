import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

typedef NotificationCallback = void Function(NotificationResponse);

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    await tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

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
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'mamba_fast_tracker',
      'Mamba Fast Tracker',
      channelDescription: 'Notifications for fasting tracker',
      importance: Importance.max,
      priority: Priority.high,
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
  }

  Future<void> scheduleNotification(
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
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
