import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/di/providers.dart';
import 'package:quex/domain/entities/entities.dart';

final appRoleProvider = StateProvider<AppRole?>((ref) => null);

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.phone,
    this.error,
    this.otpSent = false,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final String? phone;
  final String? error;
  final bool otpSent;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? phone,
    String? error,
    bool? otpSent,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      phone: phone ?? this.phone,
      error: error,
      otpSent: otpSent ?? this.otpSent,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState());

  final dynamic _repository;

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.sendOtp(phone);
      state = state.copyWith(
        isLoading: false,
        phone: phone,
        otpSent: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _repository.verifyOtp(otp);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: success,
        error: success ? null : 'Invalid OTP. Try ${AppConstants.demoOtp}',
      );
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final businessesProvider = FutureProvider<List<Business>>((ref) {
  return ref.read(businessRepositoryProvider).getNearbyBusinesses();
});

final businessSearchProvider =
    FutureProvider.family<List<Business>, String>((ref, query) {
  return ref.read(businessRepositoryProvider).searchBusinesses(query);
});

final businessDetailProvider =
    FutureProvider.family<Business?, String>((ref, id) {
  return ref.read(businessRepositoryProvider).getBusinessById(id);
});

final queueProvider =
    FutureProvider.family<List<QueueEntry>, String>((ref, businessId) {
  return ref.read(queueRepositoryProvider).getQueueForBusiness(businessId);
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) {
  return ref.read(notificationRepositoryProvider).getNotifications();
});

final profileProvider = FutureProvider<UserProfile>((ref) {
  return ref.read(profileRepositoryProvider).getProfile();
});

final analyticsProvider =
    FutureProvider.family<AnalyticsSummary, String>((ref, businessId) {
  return ref.read(analyticsRepositoryProvider).getAnalytics(businessId);
});

final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlan>>((ref) {
  return ref.read(analyticsRepositoryProvider).getSubscriptionPlans();
});

final staffQueueProvider =
    StateNotifierProvider<StaffQueueNotifier, AsyncValue<List<QueueEntry>>>(
  (ref) => StaffQueueNotifier(ref.read(queueRepositoryProvider)),
);

class StaffQueueNotifier extends StateNotifier<AsyncValue<List<QueueEntry>>> {
  StaffQueueNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    load('biz_1');
  }

  final dynamic _repository;
  String _businessId = 'biz_1';

  Future<void> load(String businessId) async {
    _businessId = businessId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.getQueueForBusiness(businessId),
    );
  }

  Future<void> refresh() => load(_businessId);

  Future<void> callNext() async {
    await _repository.callNext(_businessId);
    await refresh();
  }

  Future<void> skip(String entryId) async {
    await _repository.skipCustomer(entryId);
    await refresh();
  }

  Future<void> noShow(String entryId) async {
    await _repository.markNoShow(entryId);
    await refresh();
  }

  Future<void> complete(String entryId) async {
    await _repository.completeCustomer(entryId);
    await refresh();
  }

  Future<void> addWalkIn(String name, String service) async {
    await _repository.addWalkIn(
      businessId: _businessId,
      customerName: name,
      service: service,
    );
    await refresh();
  }
}
