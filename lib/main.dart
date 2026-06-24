import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quex/app.dart';
import 'package:quex/core/config/app_config.dart';
import 'package:quex/core/di/providers.dart';
import 'package:quex/core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.enableFirebase) {
    // await Firebase.initializeApp();
  }

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const QueXApp(),
    ),
  );
}
