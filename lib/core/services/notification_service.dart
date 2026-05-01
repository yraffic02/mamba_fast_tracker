import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef NotificationCallback = void Function(NotificationResponse);

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
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

  Future<void> notifyFastingStarted() async {
    await showNotification(
      'Fasting Started',
      'Your fasting session has begun. Good luck!',
    );
  }

  Future<void> notifyFastingEnded() async {
    await showNotification(
      'Fasting Completed',
      'Congratulations! You completed your fasting session.',
    );
  }
}
