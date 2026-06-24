import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quex/core/config/app_config.dart';

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? localNotifications})
      : _localNotifications = localNotifications;

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
  }

  Future<String?> getToken() async => null;
}
