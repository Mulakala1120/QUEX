import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/core/widgets/quex_widgets.dart';
import 'package:quex/features/customer/presentation/widgets/customer_nav_bar.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

final favoriteSalonsProvider =
    StateProvider<Set<String>>((ref) => {'biz_1'});

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(businessesProvider);
    final favorites = ref.watch(favoriteSalonsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.refresh(businessesProvider.future),
          child: businesses.when(
            data: (list) {
              final openSalons =
                  list.where((b) => b.isOpen && b.category == 'Salon').toList();
              final featured = openSalons.isNotEmpty
                  ? openSalons.reduce(
                      (a, b) => a.waitMinutes <= b.waitMinutes ? a : b,
                    )
                  : list.first;
              final others = list
                  .where((b) => b.id != featured.id)
                  .toList();

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
                                child: LocationSelector(
                                  location: 'Koramangala, Bengaluru',
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              NotificationBellButton(
                                onTap: () =>
                                    context.push('/customer/notifications'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _greeting(),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Join the queue before you arrive',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _HeroSearchCard(
                            onTap: () => context.push('/customer/search'),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Featured Nearby Salon',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FeaturedSalonCard(
                            business: featured,
                            isFavorite: favorites.contains(featured.id),
                            onCheckIn: () => context.push(
                              '/customer/business/${featured.id}',
                            ),
                            onFavorite: () {
                              final current = {...favorites};
                              if (current.contains(featured.id)) {
                                current.remove(featured.id);
                              } else {
                                current.add(featured.id);
                              }
                              ref.read(favoriteSalonsProvider.notifier).state =
                                  current;
                            },
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Other Salons Near You',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SalonListCard(
                            business: others[index],
                            onTap: () => context.push(
                              '/customer/business/${others[index].id}',
                            ),
                          ),
                        ),
                        childCount: others.length,
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const CustomScrollView(
              slivers: [
                SliverFillRemaining(child: LoadingView()),
              ],
            ),
            error: (e, _) => CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: 'Could not load salons',
                    subtitle: e.toString(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomerNavBar(currentIndex: 0),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _HeroSearchCard extends StatelessWidget {
  const _HeroSearchCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return QueXCard(
      onTap: onTap,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF0FDF4),
          Color(0xFFDCFCE7),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find a Salon Near You',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Live Wait Times Available',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.textSecondary),
                SizedBox(width: 12),
                Text(
                  'Search salons near you',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
