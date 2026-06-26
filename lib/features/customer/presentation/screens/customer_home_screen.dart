import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/core/widgets/salon_mvp_widgets.dart' as salon;
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/customer/presentation/providers/customer_session_provider.dart';
import 'package:quex/features/customer/presentation/widgets/customer_dark_widgets.dart';
import 'package:quex/features/shared/providers/app_providers.dart';
import 'package:quex/ui_kit/quex_ui_kit.dart';

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
              final salons = list.where((b) => b.category == 'Salon').toList()
                ..sort((a, b) => a.waitMinutes.compareTo(b.waitMinutes));
              final featured = salons.isNotEmpty ? salons.first : null;
              final others =
                  salons.length > 1 ? salons.sublist(1) : <Business>[];

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
                              Expanded(
                                child: profile.when(
                                  data: (p) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_rounded,
                                            color: AppColors.accent,
                                            size: 18,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Hyderabad, India',
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${_greeting()}, ${p.name.split(' ').first}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  loading: () => const SizedBox(height: 48),
                                  error: (_, __) => const SizedBox(height: 48),
                                ),
                              ),
                              const Spacer(),
                              _NotificationBell(
                                onTap: () =>
                                    context.push('/customer/notifications'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            "Find a Salon\nNear You",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              height: 1.02,
                              letterSpacing: -1.1,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _SearchBarTile(
                            onTap: () => context.push('/customer/search'),
                          ),
                          const SizedBox(height: 22),
                          if (featured != null) ...[
                            salon.FeaturedSalonCard(
                              business: featured,
                              isCheckedIn:
                                  activeCheckIn?.businessId == featured.id,
                              isFavorite: favorites.contains(featured.id),
                              onJoinQueue: () => context.push(
                                '/customer/business/${featured.id}',
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
                          const QxSectionTitle('OTHER SALONS NEAR YOU'),
                          const SizedBox(height: 12),
                          _NearbyList(
                            businesses: others,
                            onTap: (b) =>
                                context.push('/customer/business/${b.id}'),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
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

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 13,
                top: 13,
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
        ),
      ),
    );
  }
}

class _SearchBarTile extends StatelessWidget {
  const _SearchBarTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return QxGlassCard(
      onTap: onTap,
      radius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: const Row(
        children: [
          Icon(Icons.search, color: AppColors.accent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search salons or services',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(Icons.tune, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _NearbyList extends StatelessWidget {
  const _NearbyList({required this.businesses, required this.onTap});

  final List<Business> businesses;
  final void Function(Business) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          for (var i = 0; i < businesses.length; i++) ...[
            _SalonRow(
              business: businesses[i],
              onTap: () => onTap(businesses[i]),
            ),
            if (i != businesses.length - 1)
              const Divider(color: AppColors.divider, height: 1),
          ],
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    business.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                          color: business.isOpen
                              ? AppColors.accent
                              : AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '  ·  ${business.distanceMiles} km',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${business.waitMinutes} min',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w900,
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
