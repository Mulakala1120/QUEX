import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quex/app.dart';
import 'package:quex/core/di/providers.dart';
import 'package:quex/core/services/notification_service.dart';
import 'package:quex/features/customer/presentation/providers/customer_session_provider.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint(details.exceptionAsString());
      }
    };

    final notificationService = NotificationService();
    await notificationService.initialize();

    final container = ProviderContainer(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
    );
    await container.read(authHydrationProvider.future);
    container.read(activeCheckInProvider);
    container.read(favoritesProvider);

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const QueXApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('QueX error: $error');
    debugPrint('$stack');
  });
}
