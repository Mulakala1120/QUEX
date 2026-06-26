import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/salon_mvp_widgets.dart' as salon;
import 'package:quex/features/customer/presentation/providers/customer_session_provider.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

/// Business detail — hero, wait time, join waitlist (mockup screen 5).
class CustomerBusinessDetailScreen extends ConsumerWidget {
  const CustomerBusinessDetailScreen({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessDetailProvider(businessId));
    final queue = ref.watch(queueProvider(businessId));
    final activeCheckIn = ref.watch(activeCheckInProvider);

    return business.when(
      data: (b) {
        if (b == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Business not found')),
          );
        }
        const accent = AppColors.accent;
        final position = queue.maybeWhen(
          data: (entries) => entries.length + 1,
          orElse: () => b.queueCount + 1,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFEAFBF0), AppColors.surface],
                      ),
                    ),
                    child: const Center(child: salon.SalonAvatar(size: 104)),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              b.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Icon(Icons.verified, color: accent, size: 22),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        b.address,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      if (b.services.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          b.services.take(3).join(' · '),
                          style: const TextStyle(color: accent, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            b.isOpen ? 'Open' : 'Closed',
                            style: TextStyle(
                              color:
                                  b.isOpen ? AppColors.accent : AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ' • ${b.distanceMiles} km',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (b.rating > 0)
                            Text(
                              ' • ★ ${b.rating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _QuickAction(
                            icon: Icons.phone_outlined,
                            label: 'Call',
                            onTap: () {},
                          ),
                          _QuickAction(
                            icon: Icons.directions_outlined,
                            label: 'Directions',
                            onTap: () {},
                          ),
                          _QuickAction(
                            icon: Icons.content_cut_rounded,
                            label: 'Services',
                            onTap: () {},
                          ),
                          _QuickAction(
                            icon: Icons.star_outline,
                            label: 'Reviews',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimated Wait Time',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${b.waitMinutes} min',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    b.waitMinutes <= 10
                                        ? 'Low crowd'
                                        : 'Moderate crowd',
                                    style: const TextStyle(
                                      color: accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Services',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final service in const [
                            'Haircut',
                            'Haircut + Beard',
                            'Kids Haircut',
                            'Hair Color',
                            'Styling',
                          ])
                            salon.ServiceChip(label: service),
                        ],
                      ),
                      if (b.description != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          b.description!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (activeCheckIn?.businessId == b.id)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'You are already in this queue',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: b.isOpen
                        ? () {
                            if (activeCheckIn?.businessId == b.id) {
                              context.go('/customer/queue');
                            } else {
                              context.push('/customer/join-queue/$businessId');
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: const Color(0xFF0A0A0A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(
                      activeCheckIn?.businessId == b.id
                          ? 'View Live Queue'
                          : 'Join Queue',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "You're #$position in queue",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
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
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surface,
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
