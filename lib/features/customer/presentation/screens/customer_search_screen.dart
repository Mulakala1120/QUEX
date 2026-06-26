import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/business_card.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/core/widgets/quex_widgets.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:quex/features/customer/presentation/widgets/customer_nav_bar.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

enum SearchViewMode { list, map }

class CustomerSearchScreen extends ConsumerStatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  ConsumerState<CustomerSearchScreen> createState() =>
      _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends ConsumerState<CustomerSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  final Set<String> _activeFilters = {};
  SearchViewMode _viewMode = SearchViewMode.list;

  static const _filters = [
    'Open Now',
    'Favorites',
    'Lowest Wait',
    'Distance',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Business> _applyFilters(List<Business> list) {
    var filtered = list.where((b) => b.category == 'Salon').toList();

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      filtered = filtered
          .where(
            (b) =>
                b.name.toLowerCase().contains(q) ||
                b.address.toLowerCase().contains(q) ||
                b.services.any((s) => s.toLowerCase().contains(q)),
          )
          .toList();
    }

    if (_activeFilters.contains('Open Now')) {
      filtered = filtered.where((b) => b.isOpen).toList();
    }

    if (_activeFilters.contains('Favorites')) {
      final favorites = ref.read(favoriteSalonsProvider);
      filtered = filtered.where((b) => favorites.contains(b.id)).toList();
    }

    if (_activeFilters.contains('Lowest Wait')) {
      filtered.sort((a, b) => a.waitMinutes.compareTo(b.waitMinutes));
    }

    if (_activeFilters.contains('Distance')) {
      filtered.sort((a, b) => a.distanceMiles.compareTo(b.distanceMiles));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(businessesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Search salons, services...',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilterChipRow(
                    filters: _filters,
                    selected: _activeFilters,
                    onSelected: (filter) {
                      setState(() {
                        if (_activeFilters.contains(filter)) {
                          _activeFilters.remove(filter);
                        } else {
                          _activeFilters.add(filter);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ViewToggle(
                        icon: Icons.list_rounded,
                        label: 'List',
                        selected: _viewMode == SearchViewMode.list,
                        onTap: () =>
                            setState(() => _viewMode = SearchViewMode.list),
                      ),
                      const SizedBox(width: 8),
                      _ViewToggle(
                        icon: Icons.map_rounded,
                        label: 'Map',
                        selected: _viewMode == SearchViewMode.map,
                        onTap: () =>
                            setState(() => _viewMode = SearchViewMode.map),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: results.when(
                data: (list) {
                  final filtered = _applyFilters(list);

                  if (_viewMode == SearchViewMode.map) {
                    return _MapPlaceholder(count: filtered.length);
                  }

                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: _query.isEmpty
                          ? Icons.search_rounded
                          : Icons.search_off_rounded,
                      title: _query.isEmpty
                          ? 'Search for salons'
                          : 'No salons found',
                      subtitle: _query.isEmpty
                          ? 'Try "haircut", "styling", or a salon name'
                          : 'Try adjusting your filters',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => BusinessCard(
                      business: filtered[index],
                      showJoinCta: true,
                      onTap: () => context.push(
                        '/customer/business/${filtered[index].id}',
                      ),
                      onJoin: () => context.push(
                        '/customer/join-queue/${filtered[index].id}',
                      ),
                    ),
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
      bottomNavigationBar: const CustomerNavBar(currentIndex: 1),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: QueXCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$count salons nearby',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Map view coming soon',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
