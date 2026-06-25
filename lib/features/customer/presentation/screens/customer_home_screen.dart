import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/customer/presentation/providers/customer_session_provider.dart';
import 'package:quex/features/customer/presentation/widgets/customer_dark_widgets.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(businessesProvider);
    final profile = ref.watch(profileProvider);
    final activeCheckIn = ref.watch(activeCheckInProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () => ref.refresh(businessesProvider.future),
          child: businesses.when(
            data: (list) {
              final featured = list.isNotEmpty ? list.first : null;
              final others = list.length > 1 ? list.sublist(1) : <Business>[];

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'QueX',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.accent,
                                ),
                              ),
                              const Spacer(),
                              Stack(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        context.push('/customer/notifications'),
                                    icon: const Icon(Icons.notifications_outlined),
                                  ),
                                  Positioned(
                                    right: 12,
                                    top: 12,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          profile.when(
                            data: (p) => Text(
                              '${_greeting()}, ${p.name.split(' ').first} 👋',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                            loading: () => const SizedBox(height: 20),
                            error: (_, __) => const SizedBox(height: 20),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Skip the wait.\nLive your time.",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _CategoryQuickRow(
                            onSalon: () {
                              ref.read(businessFiltersProvider.notifier).state =
                                  const BusinessFilters(
                                category: 'Salon',
                                openNowOnly: true,
                              );
                              context.go('/customer/map');
                            },
                            onHealth: () {
                              ref.read(businessFiltersProvider.notifier).state =
                                  const BusinessFilters(
                                category: 'Health',
                                openNowOnly: true,
                              );
                              context.go('/customer/map');
                            },
                            onBrowse: () =>
                                context.push('/customer/categories'),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => context.push('/customer/categories'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.accent,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Find a salon near you',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (featured != null) ...[
                            _FeaturedCard(
                              business: featured,
                              isCheckedIn:
                                  activeCheckIn?.businessId == featured.id,
                              isFavorite: favorites.contains(featured.id),
                              onCheckIn: () => context.push(
                                '/customer/check-in/${featured.id}',
                              ),
                              onViewQueue: activeCheckIn != null
                                  ? () => context.go('/customer/queue')
                                  : null,
                              onFavorite: () => ref
                                  .read(favoritesProvider.notifier)
                                  .toggle(featured.id),
                            ),
                            const SizedBox(height: 28),
                          ],
                          const Text(
                            'OTHER SALONS NEAR YOU',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final b = others[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _SalonRow(
                            business: b,
                            onTap: () =>
                                context.push('/customer/check-in/${b.id}'),
                          ),
                        );
                      },
                      childCount: others.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
            loading: () => const LoadingView(),
            error: (e, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load businesses',
              subtitle: e.toString(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomerNavBar(currentIndex: 0),
    );
  }
}

class _CategoryQuickRow extends StatelessWidget {
  const _CategoryQuickRow({
    required this.onSalon,
    required this.onHealth,
    required this.onBrowse,
  });

  final VoidCallback onSalon;
  final VoidCallback onHealth;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickChip(
            icon: Icons.content_cut,
            label: 'Salons',
            onTap: onSalon,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickChip(
            icon: Icons.medical_services_outlined,
            label: 'Clinics',
            onTap: onHealth,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickChip(
            icon: Icons.grid_view_rounded,
            label: 'Browse',
            onTap: onBrowse,
          ),
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.business,
    required this.onCheckIn,
    required this.onFavorite,
    this.onViewQueue,
    this.isCheckedIn = false,
    this.isFavorite = false,
  });

  final Business business;
  final VoidCallback onCheckIn;
  final VoidCallback? onViewQueue;
  final VoidCallback onFavorite;
  final bool isCheckedIn;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCheckedIn) ...[
            const CheckedInBadge(),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: WaitTimeBadge(
                  minutes: business.waitMinutes,
                  large: true,
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  business.category == 'Clinic' ||
                          business.category == 'Hospital'
                      ? Icons.local_hospital_outlined
                      : Icons.content_cut,
                  color: AppColors.accent,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),
          Text(
            business.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
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
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                business.isOpen ? 'Open' : 'Closed',
                style: TextStyle(
                  color: business.isOpen ? AppColors.accent : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (business.isOpen && business.closesAt != null)
                Text(
                  ' • Closes ${business.closesAt}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              Text(
                ' • ${business.distanceMiles} km',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCheckIn,
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text('Check In'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_outline,
                  size: 18,
                ),
                label: const Text('Favorite'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              if (onViewQueue != null) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onViewQueue,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(52, 52),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Icon(Icons.hourglass_top_outlined),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SalonRow extends StatelessWidget {
  const _SalonRow({required this.business, required this.onTap});

  final Business business;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                business.category == 'Clinic' || business.category == 'Hospital'
                    ? Icons.medical_services_outlined
                    : Icons.content_cut,
                color: AppColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    business.address,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    business.isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                      color: business.isOpen ? AppColors.accent : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (business.isOpen)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${business.waitMinutes} min',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    'EST WAIT',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
