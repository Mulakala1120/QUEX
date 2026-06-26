import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/customer/presentation/providers/customer_session_provider.dart';
import 'package:quex/features/customer/presentation/widgets/customer_dark_widgets.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class CustomerBookingsScreen extends ConsumerStatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  ConsumerState<CustomerBookingsScreen> createState() =>
      _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState
    extends ConsumerState<CustomerBookingsScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(customerBookingsProvider);
    final activeCheckIn = ref.watch(activeCheckInProvider);
    final businesses = ref.watch(businessesProvider);

    final upcoming = upcomingBookings(bookings);
    final past = pastBookings(bookings);
    final visible = _tabIndex == 0 ? upcoming : past;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Bookings',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Appointments & visit history',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/customer/search'),
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                  ),
                ],
              ),
            ),
            if (activeCheckIn != null)
              businesses.when(
                data: (list) {
                  final business = list
                      .where((b) => b.id == activeCheckIn.businessId)
                      .firstOrNull;
                  if (business == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _ActiveQueueBanner(
                      businessName: business.name,
                      waitMinutes: activeCheckIn.entry.estimatedWaitMinutes,
                      onTap: () => context.go('/customer/queue'),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: _BookingTabs(
                index: _tabIndex,
                upcomingCount: upcoming.length,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _tabIndex == 0
                                  ? Icons.event_available_outlined
                                  : Icons.history,
                              size: 56,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _tabIndex == 0
                                  ? 'No upcoming bookings'
                                  : 'No past visits yet',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _tabIndex == 0
                                  ? 'Book a salon or clinic visit to see it here'
                                  : 'Completed and cancelled visits appear here',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (_tabIndex == 0) ...[
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: () => context.go('/customer/home'),
                                child: const Text('Browse places'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final booking = visible[index];
                        return _BookingCard(
                          booking: booking,
                          isUpcomingTab: _tabIndex == 0,
                          onTap: () => context.push(
                            '/customer/business/${booking.businessId}',
                          ),
                          onCancel: booking.isUpcoming
                              ? () => _confirmCancel(context, booking.id)
                              : null,
                          onRebook: _tabIndex != 0 &&
                                  booking.status == BookingStatus.completed
                              ? () => context.push(
                                    '/customer/check-in/${booking.businessId}',
                                  )
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/customer/home'),
              backgroundColor: AppColors.accent,
              foregroundColor: const Color(0xFF0A0A0A),
              icon: const Icon(Icons.add),
              label: const Text(
                'Book visit',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      bottomNavigationBar: const CustomerNavBar(currentIndex: -1),
    );
  }

  Future<void> _confirmCancel(BuildContext context, String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cancel booking?'),
        content: const Text(
          'This appointment will be marked as cancelled. You can book again anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Cancel booking',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!context.mounted) return;
      ref.read(customerBookingsProvider.notifier).cancelBooking(bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled')),
      );
    }
  }
}

class _BookingTabs extends StatelessWidget {
  const _BookingTabs({
    required this.index,
    required this.upcomingCount,
    required this.onChanged,
  });

  final int index;
  final int upcomingCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabChip(
              label: 'Upcoming',
              badge: upcomingCount > 0 ? '$upcomingCount' : null,
              isActive: index == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabChip(
              label: 'Past',
              isActive: index == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? const Color(0xFF0A0A0A)
                      : AppColors.textSecondary,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF0A0A0A).withValues(alpha: 0.15)
                        : AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color:
                          isActive ? const Color(0xFF0A0A0A) : AppColors.accent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveQueueBanner extends StatelessWidget {
  const _ActiveQueueBanner({
    required this.businessName,
    required this.waitMinutes,
    required this.onTap,
  });

  final String businessName;
  final int waitMinutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LIVE QUEUE',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      businessName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '~$waitMinutes min wait',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.isUpcomingTab,
    required this.onTap,
    this.onCancel,
    this.onRebook,
  });

  final CustomerBooking booking;
  final bool isUpcomingTab;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onRebook;

  @override
  Widget build(BuildContext context) {
    final isHealth =
        booking.category == 'Clinic' || booking.category == 'Hospital';
    final accent = isHealth ? AppColors.clinicBlue : AppColors.accent;
    final dateFmt = DateFormat('EEE, d MMM');
    final timeFmt = DateFormat('h:mm a');

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isHealth
                          ? Icons.local_hospital_outlined
                          : Icons.content_cut,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.businessName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.service,
                          style: TextStyle(color: accent, fontSize: 13),
                        ),
                        if (booking.notes != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            booking.notes!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _StatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${dateFmt.format(booking.scheduledAt)} · ${timeFmt.format(booking.scheduledAt)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (booking.address != null) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        booking.address!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (isUpcomingTab && booking.isUpcoming) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reschedule — coming in Phase B'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('Reschedule'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: onCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          minimumSize: const Size(0, 40),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
              if (!isUpcomingTab && onRebook != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onRebook,
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40)),
                    child: const Text('Book again'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BookingStatus.confirmed => ('Confirmed', AppColors.accent),
      BookingStatus.pending => ('Pending', AppColors.warning),
      BookingStatus.completed => ('Completed', AppColors.textSecondary),
      BookingStatus.cancelled => ('Cancelled', AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
