import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/customer/presentation/providers/customer_session_provider.dart';

class CustomerNavBar extends StatelessWidget {
  const CustomerNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => context.go('/customer/home'),
              ),
              _NavItem(
                icon: Icons.search,
                activeIcon: Icons.search,
                label: 'Search',
                isActive: currentIndex == 1,
                onTap: () => context.go('/customer/search'),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: currentIndex == 2,
                onTap: () => context.go('/customer/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeIcon,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.accent : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Icon(
          isActive ? (activeIcon ?? icon) : icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}

class QueXDarkScaffold extends StatelessWidget {
  const QueXDarkScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.showBack = false,
    this.bottomNavIndex,
    this.floatingActionButton,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final bool showBack;
  final int? bottomNavIndex;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: title != null
          ? AppBar(
              title: Text(
                title!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              leading: showBack
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    )
                  : null,
              actions: actions,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavIndex != null
          ? CustomerNavBar(currentIndex: bottomNavIndex!)
          : null,
    );
  }
}

class WaitTimeBadge extends StatelessWidget {
  const WaitTimeBadge({super.key, required this.minutes, this.large = false});

  final int minutes;
  final bool large;

  @override
  Widget build(BuildContext context) {
    if (large) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR ESTIMATED WAIT',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$minutes min',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$minutes min',
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          'EST WAIT',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class CheckedInBadge extends StatelessWidget {
  const CheckedInBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'CHECKED IN',
        style: TextStyle(
          color: Color(0xFF1A1D26),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class SalonListTile extends StatelessWidget {
  const SalonListTile({
    super.key,
    required this.business,
    required this.onTap,
    this.showCheckedIn = false,
  });

  final Business business;
  final VoidCallback onTap;
  final bool showCheckedIn;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCheckedIn) ...[
                    const CheckedInBadge(),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    business.address,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  if (business.landmark != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      business.landmark!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        business.isOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          color: business.isOpen
                              ? AppColors.accent
                              : AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (business.isOpen && business.closesAt != null) ...[
                        Text(
                          ' • Closes ${business.closesAt}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      Text(
                        ' • ${business.distanceMiles} km',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (business.isOpen) WaitTimeBadge(minutes: business.waitMinutes),
          ],
        ),
      ),
    );
  }
}

class DarkCard extends StatelessWidget {
  const DarkCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class FilterChipRow extends ConsumerWidget {
  const FilterChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(businessFiltersProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(
            label: _sortLabel(filters.sort),
            selected: false,
            onTap: () => _pickSort(context, ref, filters),
          ),
          _chip(
            label: 'Favorite',
            selected: filters.favoritesOnly,
            onTap: () => ref.read(businessFiltersProvider.notifier).state =
                filters.copyWith(favoritesOnly: !filters.favoritesOnly),
          ),
          _chip(
            label: 'Open now',
            selected: filters.openNowOnly,
            onTap: () => ref.read(businessFiltersProvider.notifier).state =
                filters.copyWith(openNowOnly: !filters.openNowOnly),
          ),
        ],
      ),
    );
  }

  String _sortLabel(BusinessSort sort) {
    switch (sort) {
      case BusinessSort.waitTime:
        return 'Sort: Wait';
      case BusinessSort.distance:
        return 'Sort: Distance';
      case BusinessSort.name:
        return 'Sort: Name';
    }
  }

  Future<void> _pickSort(
    BuildContext context,
    WidgetRef ref,
    BusinessFilters filters,
  ) async {
    final picked = await showModalBottomSheet<BusinessSort>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: BusinessSort.values
            .map(
              (s) => Material(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(_sortLabel(s).replaceFirst('Sort: ', '')),
                  onTap: () => Navigator.pop(ctx, s),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (picked != null) {
      ref.read(businessFiltersProvider.notifier).state =
          filters.copyWith(sort: picked);
    }
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.surfaceLight,
        labelStyle: TextStyle(
          color: selected ? AppColors.accent : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        side: BorderSide(
          color: selected ? AppColors.accent : AppColors.divider,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class MapListToggle extends StatelessWidget {
  const MapListToggle({
    super.key,
    required this.isMapView,
    required this.onChanged,
  });

  final bool isMapView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment('Map View', isMapView, () => onChanged(true)),
          _segment('List View', !isMapView, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _segment(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.background : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
