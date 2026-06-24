import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quex/core/network/api_client.dart';
import 'package:quex/core/services/firebase_auth_service.dart';
import 'package:quex/core/services/notification_service.dart';
import 'package:quex/data/repositories/repository_impl.dart';
import 'package:quex/domain/repositories/repositories.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final firebaseAuthServiceProvider =
    Provider<FirebaseAuthService>((ref) => FirebaseAuthService());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final businessRepositoryProvider = Provider<BusinessRepository>(
  (ref) => BusinessRepositoryImpl(),
);

final queueRepositoryProvider = Provider<QueueRepository>(
  (ref) => QueueRepositoryImpl(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(),
);

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => AnalyticsRepositoryImpl(),
);
