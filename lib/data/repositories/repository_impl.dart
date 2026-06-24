import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/data/datasources/dummy_data_source.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/domain/repositories/repositories.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  @override
  Future<List<Business>> getNearbyBusinesses() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List.of(DummyDataSource.businesses)
      ..sort((a, b) => a.distanceMiles.compareTo(b.distanceMiles));
  }

  @override
  Future<List<Business>> searchBusinesses(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return getNearbyBusinesses();
    return DummyDataSource.businesses
        .where(
          (b) =>
              b.name.toLowerCase().contains(q) ||
              b.category.toLowerCase().contains(q) ||
              b.services.any((s) => s.toLowerCase().contains(q)),
        )
        .toList();
  }

  @override
  Future<Business?> getBusinessById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return DummyDataSource.businesses.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

class QueueRepositoryImpl implements QueueRepository {
  String? _activeCustomerEntryId = 'q_4';

  @override
  Future<List<QueueEntry>> getQueueForBusiness(String businessId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.of(DummyDataSource.queues[businessId] ?? []);
  }

  @override
  Future<QueueEntry> joinQueue({
    required String businessId,
    required String customerName,
    required String service,
    String? phone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final queue = DummyDataSource.queues.putIfAbsent(businessId, () => []);
    final entry = QueueEntry(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
      position: queue.length + 1,
      customerName: customerName,
      service: service,
      status: QueueStatus.waiting,
      estimatedWaitMinutes: (queue.length + 1) * 10,
      phone: phone,
      joinedAt: DateTime.now(),
    );
    queue.add(entry);
    _activeCustomerEntryId = entry.id;
    return entry;
  }

  @override
  Future<QueueEntry?> getActiveQueueForCustomer(String customerId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    for (final queue in DummyDataSource.queues.values) {
      for (final entry in queue) {
        if (entry.id == _activeCustomerEntryId) return entry;
      }
    }
    return null;
  }

  @override
  Future<void> callNext(String businessId) async {
    final queue = DummyDataSource.queues[businessId];
    if (queue == null) return;
    final next = queue.firstWhere(
      (e) => e.status == QueueStatus.waiting,
      orElse: () => queue.first,
    );
    final index = queue.indexOf(next);
    queue[index] = next.copyWith(status: QueueStatus.called);
  }

  @override
  Future<void> skipCustomer(String entryId) async {
    _updateEntry(entryId, QueueStatus.skipped);
  }

  @override
  Future<void> markNoShow(String entryId) async {
    _updateEntry(entryId, QueueStatus.noShow);
  }

  @override
  Future<void> completeCustomer(String entryId) async {
    _updateEntry(entryId, QueueStatus.completed);
  }

  @override
  Future<QueueEntry> addWalkIn({
    required String businessId,
    required String customerName,
    required String service,
  }) async {
    return joinQueue(
      businessId: businessId,
      customerName: customerName,
      service: service,
    );
  }

  void _updateEntry(String entryId, QueueStatus status) {
    for (final queue in DummyDataSource.queues.values) {
      for (var i = 0; i < queue.length; i++) {
        if (queue[i].id == entryId) {
          queue[i] = queue[i].copyWith(status: status);
          return;
        }
      }
    }
  }
}

class AuthRepositoryImpl implements AuthRepository {
  bool _authenticated = false;
  String? _phone;
  String? _verificationId;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  String? get phoneNumber => _phone;

  @override
  Future<void> sendOtp(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _phone = phone;
    _verificationId = 'demo-verification-id';
  }

  @override
  Future<bool> verifyOtp(String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (otp == AppConstants.demoOtp || otp.length == AppConstants.otpLength) {
      _authenticated = true;
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    _authenticated = false;
    _phone = null;
    _verificationId = null;
  }
}

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.of(DummyDataSource.notifications);
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<UserProfile> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return DummyDataSource.defaultProfile;
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  @override
  Future<AnalyticsSummary> getAnalytics(String businessId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return DummyDataSource.defaultAnalytics;
  }

  @override
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.of(DummyDataSource.subscriptionPlans);
  }
}
