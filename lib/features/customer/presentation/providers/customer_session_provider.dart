import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/di/providers.dart';
import 'package:quex/core/services/session_storage.dart';
import 'package:quex/data/datasources/dummy_data_source.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

enum BusinessSort { waitTime, distance, name }

class BusinessFilters {
  const BusinessFilters({
    this.category,
    this.openNowOnly = false,
    this.favoritesOnly = false,
    this.sort = BusinessSort.waitTime,
  });

  final String? category;
  final bool openNowOnly;
  final bool favoritesOnly;
  final BusinessSort sort;

  BusinessFilters copyWith({
    String? category,
    bool? openNowOnly,
    bool? favoritesOnly,
    BusinessSort? sort,
    bool clearCategory = false,
  }) {
    return BusinessFilters(
      category: clearCategory ? null : (category ?? this.category),
      openNowOnly: openNowOnly ?? this.openNowOnly,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sort: sort ?? this.sort,
    );
  }
}

final businessFiltersProvider = StateProvider<BusinessFilters>(
  (ref) => const BusinessFilters(),
);

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier(ref.read(sessionStorageProvider));
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._storage) : super({}) {
    _load();
  }

  final SessionStorage _storage;

  Future<void> _load() async {
    state = await _storage.getFavorites();
  }

  Future<void> toggle(String businessId) async {
    final next = Set<String>.from(state);
    if (next.contains(businessId)) {
      next.remove(businessId);
    } else {
      next.add(businessId);
    }
    state = next;
    await _storage.setFavorites(next);
  }

  bool isFavorite(String businessId) => state.contains(businessId);
}

final activeCheckInProvider =
    StateNotifierProvider<ActiveCheckInNotifier, ActiveCheckIn?>((ref) {
  return ActiveCheckInNotifier(
    ref.read(queueRepositoryProvider),
    ref.read(sessionStorageProvider),
  );
});

class ActiveCheckIn {
  const ActiveCheckIn({
    required this.businessId,
    required this.entryId,
    required this.entry,
  });

  final String businessId;
  final String entryId;
  final QueueEntry entry;
}

class ActiveCheckInNotifier extends StateNotifier<ActiveCheckIn?> {
  ActiveCheckInNotifier(this._queueRepo, this._storage) : super(null) {
    _restore();
  }

  final dynamic _queueRepo;
  final SessionStorage _storage;

  Future<void> _restore() async {
    final saved = await _storage.getCheckIn();
    if (saved != null) {
      final queue = await _queueRepo.getQueueForBusiness(saved.businessId);
      for (final entry in queue) {
        if (entry.id == saved.entryId &&
            entry.customerName == 'You' &&
            _isActive(entry)) {
          state = ActiveCheckIn(
            businessId: saved.businessId,
            entryId: saved.entryId,
            entry: entry,
          );
          return;
        }
      }
      await _storage.clearCheckIn();
    }

    for (final businessId in DummyDataSource.queues.keys) {
      final queue = await _queueRepo.getQueueForBusiness(businessId);
      for (final entry in queue) {
        if (entry.customerName == 'You' && _isActive(entry)) {
          state = ActiveCheckIn(
            businessId: businessId,
            entryId: entry.id,
            entry: entry,
          );
          await _storage.saveCheckIn(
            businessId: businessId,
            entryId: entry.id,
          );
          return;
        }
      }
    }
  }

  bool _isActive(QueueEntry entry) =>
      entry.status != QueueStatus.completed &&
      entry.status != QueueStatus.skipped &&
      entry.status != QueueStatus.noShow;

  Future<void> setCheckIn({
    required String businessId,
    required QueueEntry entry,
  }) async {
    state = ActiveCheckIn(
      businessId: businessId,
      entryId: entry.id,
      entry: entry,
    );
    await _storage.saveCheckIn(
      businessId: businessId,
      entryId: entry.id,
    );
  }

  Future<void> cancelCheckIn() async {
    if (state == null) return;
    await _queueRepo.leaveQueue(state!.entryId);
    state = null;
    await _storage.clearCheckIn();
  }

  Future<void> refresh() async {
    if (state == null) return;
    final queue = await _queueRepo.getQueueForBusiness(state!.businessId);
    for (final entry in queue) {
      if (entry.id == state!.entryId) {
        if (entry.status == QueueStatus.completed ||
            entry.status == QueueStatus.skipped ||
            entry.status == QueueStatus.noShow) {
          state = null;
          await _storage.clearCheckIn();
        } else {
          state = ActiveCheckIn(
            businessId: state!.businessId,
            entryId: entry.id,
            entry: entry,
          );
        }
        return;
      }
    }
    state = null;
    await _storage.clearCheckIn();
  }
}

final filteredBusinessesProvider = FutureProvider<List<Business>>((ref) async {
  final businesses = await ref.watch(businessesProvider.future);
  final filters = ref.watch(businessFiltersProvider);
  final favorites = ref.watch(favoritesProvider);

  var result = List<Business>.from(businesses);

  if (filters.category != null) {
    if (filters.category == 'Health') {
      result = result
          .where((b) => b.category == 'Clinic' || b.category == 'Hospital')
          .toList();
    } else {
      result = result.where((b) => b.category == filters.category).toList();
    }
  }
  if (filters.openNowOnly) {
    result = result.where((b) => b.isOpen).toList();
  }
  if (filters.favoritesOnly) {
    result = result.where((b) => favorites.contains(b.id)).toList();
  }

  switch (filters.sort) {
    case BusinessSort.waitTime:
      result.sort((a, b) => a.waitMinutes.compareTo(b.waitMinutes));
    case BusinessSort.distance:
      result.sort((a, b) => a.distanceMiles.compareTo(b.distanceMiles));
    case BusinessSort.name:
      result.sort((a, b) => a.name.compareTo(b.name));
  }

  return result;
});
