import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/business_card.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(businessesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(businessesProvider.future),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const QueXLogo(size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const Text(
                                  'Find a salon or clinic near you',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.push('/customer/notifications'),
                            icon: const Icon(Icons.notifications_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => context.push('/customer/search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search, color: AppColors.textSecondary),
                              SizedBox(width: 12),
                              Text(
                                'Search salons, clinics, services...',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nearby',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () => context.push('/customer/queue'),
                            child: const Text('My Queue'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              businesses.when(
                data: (list) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => BusinessCard(
                        business: list[index],
                        onTap: () => context.push(
                          '/customer/business/${list[index].id}',
                        ),
                      ),
                      childCount: list.length,
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  child: LoadingView(),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: 'Could not load businesses',
                    subtitle: e.toString(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _CustomerNavBar(currentIndex: 0),
    );
  }
}

class _CustomerNavBar extends StatelessWidget {
  const _CustomerNavBar({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        switch (i) {
          case 0:
            context.go('/customer/home');
          case 1:
            context.go('/customer/search');
          case 2:
            context.go('/customer/queue');
          case 3:
            context.go('/customer/profile');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.hourglass_top_outlined),
          label: 'Queue',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
