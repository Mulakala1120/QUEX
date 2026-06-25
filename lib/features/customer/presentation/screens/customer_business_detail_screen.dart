import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/app_theme.dart';
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
        final isHealth = b.category == 'Clinic' || b.category == 'Hospital';
        final accent = isHealth ? AppColors.clinicBlue : AppColors.accent;
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isHealth
                            ? [const Color(0xFF0C4A6E), AppColors.surface]
                            : [const Color(0xFF365314), AppColors.surface],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isHealth
                            ? Icons.local_hospital_outlined
                            : Icons.storefront_outlined,
                        size: 72,
                        color: accent.withValues(alpha: 0.5),
                      ),
                    ),
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
                          Icon(Icons.verified, color: accent, size: 22),
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
                          style: TextStyle(color: accent, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            b.isOpen ? 'Open' : 'Closed',
                            style: TextStyle(
                              color: b.isOpen ? accent : AppColors.error,
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
                            icon: Icons.medical_services_outlined,
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
                                  style: TextStyle(
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
                                    style: TextStyle(
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
                      if (isHealth) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Available now',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DoctorRow(
                          name: 'Dr. Priya Sharma',
                          specialty: 'General Physician',
                          nextIn: '${b.waitMinutes + 5} min',
                          accent: accent,
                        ),
                        _DoctorRow(
                          name: 'Dr. Rahul Verma',
                          specialty: 'Dermatology',
                          nextIn: '${b.waitMinutes + 15} min',
                          accent: accent,
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
                              context.push('/customer/check-in/$businessId');
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
                          : 'Join Waitlist',
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
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DoctorRow extends StatelessWidget {
  const _DoctorRow({
    required this.name,
    required this.specialty,
    required this.nextIn,
    required this.accent,
  });

  final String name;
  final String specialty;
  final String nextIn;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: accent.withValues(alpha: 0.2),
            child: Icon(Icons.person, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  specialty,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Next in $nextIn',
            style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
