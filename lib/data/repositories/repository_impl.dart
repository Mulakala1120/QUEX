import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/services/session_storage.dart';
import 'package:quex/data/datasources/dummy_data_source.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/domain/repositories/repositories.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  @override
  Future<List<Business>> getNearbyBusinesses({
    int page = 0,
    int limit = 50,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final sorted = List<Business>.from(DummyDataSource.businesses)
      ..sort((a, b) => a.distanceMiles.compareTo(b.distanceMiles));
    final start = page * limit;
    if (start >= sorted.length) return [];
    final end = (start + limit).clamp(0, sorted.length);
    return sorted.sublist(start, end);
  }

  @override
  Future<List<Business>> searchBusinesses(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
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
  Future<List<Business>> getByCategory(String category) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return DummyDataSource.businesses
        .where((b) => b.category == category)
        .toList()
      ..sort((a, b) => a.waitMinutes.compareTo(b.waitMinutes));
  }

  @override
  Future<Business?> getBusinessById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    try {
      return DummyDataSource.businesses.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

class QueueRepositoryImpl implements QueueRepository {
  QueueRepositoryImpl();

  String? _activeCustomerEntryId = 'q_4';
  String? _activeBusinessId = 'biz_1';

  @override
  Future<List<QueueEntry>> getQueueForBusiness(String businessId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List.of(DummyDataSource.queues[businessId] ?? []);
  }

  @override
  Future<QueueEntry> joinQueue({
    required String businessId,
    required String customerName,
    required String service,
    String? phone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_activeCustomerEntryId != null) {
      await leaveQueue(_activeCustomerEntryId!);
    }

    final queue = DummyDataSource.queues.putIfAbsent(businessId, () => []);
    final waitingAhead =
        queue.where((e) => e.status == QueueStatus.waiting).length;
    final entry = QueueEntry(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
      position: waitingAhead + 1,
      customerName: customerName,
      service: service,
      status: QueueStatus.waiting,
      estimatedWaitMinutes: (waitingAhead + 1) * 10,
      phone: phone,
      joinedAt: DateTime.now(),
    );
    queue.add(entry);
    _activeCustomerEntryId = entry.id;
    _activeBusinessId = businessId;
    return entry;
  }

  @override
  Future<QueueEntry?> getActiveQueueForCustomer(String customerId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (_activeCustomerEntryId == null || _activeBusinessId == null) {
      return null;
    }
    final queue = DummyDataSource.queues[_activeBusinessId];
    if (queue == null) return null;
    for (final entry in queue) {
      if (entry.id == _activeCustomerEntryId) return entry;
    }
    return null;
  }

  @override
  Future<void> leaveQueue(String entryId) async {
    for (final businessId in DummyDataSource.queues.keys.toList()) {
      final queue = DummyDataSource.queues[businessId]!;
      queue.removeWhere((e) => e.id == entryId);
      _reindexQueue(queue);
    }
    if (_activeCustomerEntryId == entryId) {
      _activeCustomerEntryId = null;
      _activeBusinessId = null;
    }
  }

  void _reindexQueue(List<QueueEntry> queue) {
    var position = 1;
    for (var i = 0; i < queue.length; i++) {
      if (queue[i].status == QueueStatus.waiting) {
        queue[i] = queue[i].copyWith(
          position: position,
          estimatedWaitMinutes: position * 10,
        );
        position++;
      }
    }
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
          if (entryId == _activeCustomerEntryId &&
              (status == QueueStatus.completed ||
                  status == QueueStatus.skipped ||
                  status == QueueStatus.noShow)) {
            _activeCustomerEntryId = null;
            _activeBusinessId = null;
          }
          return;
        }
      }
    }
  }
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._storage);

  final SessionStorage _storage;
  bool _authenticated = false;
  String? _phone;
  bool _hydrated = false;

  Future<void> hydrate() async {
    if (_hydrated) return;
    _authenticated = await _storage.isAuthenticated();
    _phone = await _storage.getPhone();
    _hydrated = true;
  }

  @override
  bool get isAuthenticated => _authenticated;

  @override
  String? get phoneNumber => _phone;

  @override
  Future<void> sendOtp(String phone) async {
    await hydrate();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _phone = phone;
  }

  @override
  Future<bool> verifyOtp(String otp) async {
    await hydrate();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (otp == AppConstants.demoOtp || otp.length == AppConstants.otpLength) {
      _authenticated = true;
      await _storage.setAuthenticated(true, phone: _phone);
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    _authenticated = false;
    _phone = null;
    await _storage.setAuthenticated(false);
  }
}

class NotificationRepositoryImpl implements NotificationRepository {
  final _readIds = <String>{};

  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return DummyDataSource.notifications
        .map(
          (n) => _readIds.contains(n.id)
              ? AppNotification(
                  id: n.id,
                  title: n.title,
                  body: n.body,
                  createdAt: n.createdAt,
                  isRead: true,
                )
              : n,
        )
        .toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    _readIds.add(id);
  }
}

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._storage);

  final SessionStorage _storage;
  UserProfile? _cached;

  @override
  Future<UserProfile> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final phone = await _storage.getPhone();
    final base = DummyDataSource.defaultProfile;
    _cached = UserProfile(
      id: base.id,
      name: base.name,
      phone: phone ?? base.phone,
      email: base.email,
      avatarUrl: base.avatarUrl,
    );
    return _cached!;
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _cached = profile;
  }
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  @override
  Future<AnalyticsSummary> getAnalytics(String businessId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return DummyDataSource.defaultAnalytics;
  }

  @override
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.of(DummyDataSource.subscriptionPlans);
  }
}
