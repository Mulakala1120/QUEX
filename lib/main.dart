import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quex/app.dart';
import 'package:quex/core/di/providers.dart';
import 'package:quex/core/services/notification_service.dart';
import 'package:quex/firebase_options.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint(details.exceptionAsString());
      }
    };

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase init note: $e');
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
  }, (error, stack) {
    debugPrint('QueX error: $error');
    debugPrint('$stack');
  });
}
