import 'package:quex/domain/entities/entities.dart';

abstract class BusinessRepository {
  Future<List<Business>> getNearbyBusinesses({int page = 0, int limit = 50});
  Future<List<Business>> searchBusinesses(String query);
  Future<List<Business>> getByCategory(String category);
  Future<Business?> getBusinessById(String id);
}

abstract class QueueRepository {
  Future<List<QueueEntry>> getQueueForBusiness(String businessId);
  Future<QueueEntry> joinQueue({
    required String businessId,
    required String customerName,
    required String service,
    String? phone,
  });
  Future<QueueEntry?> getActiveQueueForCustomer(String customerId);
  Future<void> leaveQueue(String entryId);
  Future<void> callNext(String businessId);
  Future<void> skipCustomer(String entryId);
  Future<void> markNoShow(String entryId);
  Future<void> completeCustomer(String entryId);
  Future<QueueEntry> addWalkIn({
    required String businessId,
    required String customerName,
    required String service,
  });
}

abstract class AuthRepository {
  Future<void> sendOtp(String phone);
  Future<bool> verifyOtp(String otp);
  Future<void> logout();
  bool get isAuthenticated;
  String? get phoneNumber;
}

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> markAsRead(String id);
}

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<void> updateProfile(UserProfile profile);
}

abstract class AnalyticsRepository {
  Future<AnalyticsSummary> getAnalytics(String businessId);
  Future<List<SubscriptionPlan>> getSubscriptionPlans();
}
