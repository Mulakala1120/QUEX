import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quex/core/config/app_config.dart';

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging,
        _localNotifications = localNotifications;

  final FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin? _localNotifications;

  Future<void> initialize() async {
    if (!AppConfig.enablePushNotifications || kIsWeb) return;

    final localNotifications =
        _localNotifications ?? FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    final messaging = _messaging ?? FirebaseMessaging.instance;
    await messaging.requestPermission();
    FirebaseMessaging.onMessage.listen(
      (message) => _showForegroundNotification(localNotifications, message),
    );
  }

  Future<String?> getToken() async {
    if (!AppConfig.enablePushNotifications || kIsWeb) return null;
    final messaging = _messaging ?? FirebaseMessaging.instance;
    return messaging.getToken();
  }

  void _showForegroundNotification(
    FlutterLocalNotificationsPlugin localNotifications,
    RemoteMessage message,
  ) {
    final notification = message.notification;
    if (notification == null) return;

    localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quex_channel',
          'QueX Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
