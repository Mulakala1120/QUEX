import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quex/core/network/api_client.dart';
import 'package:quex/core/services/notification_service.dart';
import 'package:quex/core/services/session_storage.dart';
import 'package:quex/data/repositories/repository_impl.dart';
import 'package:quex/domain/repositories/repositories.dart';

final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => SessionStorage(),
);

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final businessRepositoryProvider = Provider<BusinessRepository>(
  (ref) => BusinessRepositoryImpl(),
);

final queueRepositoryProvider = Provider<QueueRepository>(
  (ref) => QueueRepositoryImpl(),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(sessionStorageProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.read(sessionStorageProvider)),
);

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => AnalyticsRepositoryImpl(),
);
