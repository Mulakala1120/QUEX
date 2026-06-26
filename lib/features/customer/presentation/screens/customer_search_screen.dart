import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/core/widgets/salon_mvp_widgets.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/customer/presentation/providers/customer_session_provider.dart';
import 'package:quex/features/customer/presentation/widgets/customer_dark_widgets.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class CustomerSearchScreen extends ConsumerStatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  ConsumerState<CustomerSearchScreen> createState() =>
      _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends ConsumerState<CustomerSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  bool _openNowOnly = false;
  bool _favoritesOnly = false;
  bool _lowestWaitFirst = true;
  bool _mapView = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(businessesProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 14),
              SearchBarWidget(
                controller: _controller,
                hintText: 'Search salons or services',
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterPill(
                    label: 'Open Now',
                    selected: _openNowOnly,
                    onTap: () => setState(() => _openNowOnly = !_openNowOnly),
                  ),
                  _FilterPill(
                    label: 'Favorites',
                    selected: _favoritesOnly,
                    onTap: () =>
                        setState(() => _favoritesOnly = !_favoritesOnly),
                  ),
                  _FilterPill(
                    label: 'Lowest Wait',
                    selected: _lowestWaitFirst,
                    onTap: () => setState(() => _lowestWaitFirst = true),
                  ),
                  _FilterPill(
                    label: 'Distance',
                    selected: !_lowestWaitFirst,
                    onTap: () => setState(() => _lowestWaitFirst = false),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _MapListToggle(
                mapView: _mapView,
                onChanged: (value) => setState(() => _mapView = value),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: results.when(
                  data: (list) {
                    final filtered = _filterSalons(list, favorites);
                    if (filtered.isEmpty) {
                      return const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No salons found',
                        subtitle: 'Try changing your search or filters',
                      );
                    }

                    if (_mapView) {
                      return _MapPlaceholder(count: filtered.length);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 110),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final salon = filtered[index];
                        return SalonCard(
                          business: salon,
                          isFavorite: favorites.contains(salon.id),
                          onFavorite: () => ref
                              .read(favoritesProvider.notifier)
                              .toggle(salon.id),
                          onTap: () =>
                              context.push('/customer/business/${salon.id}'),
                        );
                      },
                    );
                  },
                  loading: () => const LoadingView(),
                  error: (e, _) => EmptyState(
                    icon: Icons.error_outline,
                    title: 'Search failed',
                    subtitle: e.toString(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomerNavBar(currentIndex: 1),
    );
  }

  List<Business> _filterSalons(List<Business> list, Set<String> favorites) {
    final q = _query.trim().toLowerCase();
    final filtered = list.where((b) {
      if (b.category != 'Salon') return false;
      if (_openNowOnly && !b.isOpen) return false;
      if (_favoritesOnly && !favorites.contains(b.id)) return false;
      if (q.isEmpty) return true;
      return b.name.toLowerCase().contains(q) ||
          b.address.toLowerCase().contains(q) ||
          b.services.any((s) => s.toLowerCase().contains(q));
    }).toList();

    if (_lowestWaitFirst) {
      filtered.sort((a, b) => a.waitMinutes.compareTo(b.waitMinutes));
    } else {
      filtered.sort((a, b) => a.distanceMiles.compareTo(b.distanceMiles));
    }
    return filtered;
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.accent,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: selected ? AppColors.accent : AppColors.divider),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _MapListToggle extends StatelessWidget {
  const _MapListToggle({required this.mapView, required this.onChanged});

  final bool mapView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'List',
              selected: !mapView,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: 'Map',
              selected: mapView,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.map_outlined,
                color: AppColors.accent,
                size: 54,
              ),
              const SizedBox(height: 14),
              Text(
                '$count salons nearby',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Use list view to choose a salon for this MVP build.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
