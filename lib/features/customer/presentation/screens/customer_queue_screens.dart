import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/di/providers.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/core/widgets/salon_mvp_widgets.dart' as salon;
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/customer/presentation/providers/customer_session_provider.dart';
import 'package:quex/features/customer/presentation/widgets/customer_dark_widgets.dart';
import 'package:quex/features/shared/providers/app_providers.dart';
import 'package:url_launcher/url_launcher.dart';

enum NotificationPreference { push, text, none }

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key, required this.businessId});

  final String businessId;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  NotificationPreference _notification = NotificationPreference.text;
  int _peopleCount = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessDetailProvider(widget.businessId));
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Check In',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: business.when(
        data: (b) {
          if (b == null) {
            return const EmptyState(
                icon: Icons.store_outlined, title: 'Not found');
          }
          final name = profile.maybeWhen(
            data: (p) => p.name,
            orElse: () => 'Guest',
          );
          final phone = profile.maybeWhen(
            data: (p) => p.phone,
            orElse: () => '',
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.accent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.address,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        if (b.landmark != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            b.landmark!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _FieldLabel(label: 'Full name', value: name),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _pickPeople(context),
                child: _FieldLabel(
                  label: 'Number of people getting haircuts',
                  value:
                      '$_peopleCount ${_peopleCount == 1 ? 'person' : 'people'}',
                  trailing: const Icon(Icons.expand_more,
                      color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 20),
              _FieldLabel(label: 'Phone number', value: phone),
              const SizedBox(height: 32),
              const Text(
                'How would you like to receive notifications for this salon visit?',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 16),
              _NotificationOption(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                selected: _notification == NotificationPreference.push,
                onTap: () => setState(
                  () => _notification = NotificationPreference.push,
                ),
              ),
              const SizedBox(height: 12),
              _NotificationOption(
                icon: Icons.sms_outlined,
                title: 'Text Messages',
                selected: _notification == NotificationPreference.text,
                onTap: () => setState(
                  () => _notification = NotificationPreference.text,
                ),
                subtitle:
                    'By selecting Text Messages, you agree to receive automated SMS about your visit. Message & data rates may apply.',
              ),
              const SizedBox(height: 12),
              _NotificationOption(
                icon: Icons.phonelink_erase_outlined,
                title: 'None',
                selected: _notification == NotificationPreference.none,
                onTap: () => setState(
                  () => _notification = NotificationPreference.none,
                ),
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Powered by QueX Net Check In™',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _checkIn(b, name, phone),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Check In'),
              ),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(icon: Icons.error, title: e.toString()),
      ),
    );
  }

  Future<void> _pickPeople(BuildContext context) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: List.generate(
          6,
          (i) => ListTile(
            title: Text('${i + 1} ${i == 0 ? 'person' : 'people'}'),
            onTap: () => Navigator.pop(ctx, i + 1),
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _peopleCount = picked);
  }

  Future<void> _checkIn(Business b, String name, String phone) async {
    setState(() => _isLoading = true);
    final service = b.services.isNotEmpty ? b.services.first : 'Haircut';
    final entry = await ref.read(queueRepositoryProvider).joinQueue(
          businessId: widget.businessId,
          customerName: 'You',
          service: service,
          phone: phone,
        );
    await ref.read(activeCheckInProvider.notifier).setCheckIn(
          businessId: widget.businessId,
          entry: entry,
        );
    ref.invalidate(queueProvider(widget.businessId));
    if (!mounted) return;
    context.go('/customer/queue');
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: AppColors.divider, height: 1),
      ],
    );
  }
}

class _NotificationOption extends StatelessWidget {
  const _NotificationOption({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color:
                          selected ? AppColors.accent : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.accent : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class LiveQueueScreen extends ConsumerStatefulWidget {
  const LiveQueueScreen({super.key});

  @override
  ConsumerState<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends ConsumerState<LiveQueueScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration.zero, () {
      ref.read(activeCheckInProvider.notifier).refresh();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      ref.read(activeCheckInProvider.notifier).refresh();
      final id = ref.read(activeCheckInProvider)?.businessId;
      if (id != null) ref.invalidate(queueProvider(id));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkIn = ref.watch(activeCheckInProvider);
    final businessId = checkIn?.businessId;
    final queue = businessId != null
        ? ref.watch(queueProvider(businessId))
        : const AsyncValue<List<QueueEntry>>.data([]);
    final business = businessId != null
        ? ref.watch(businessDetailProvider(businessId))
        : const AsyncValue<Business?>.data(null);

    ref.listen(activeCheckInProvider, (_, next) {
      if (next != null && businessId != null) {
        ref.invalidate(queueProvider(businessId));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: checkIn == null
            ? Column(
                children: [
                  _QueueHeader(onNotifications: () {
                    context.push('/customer/notifications');
                  }),
                  const Expanded(
                    child: EmptyState(
                      icon: Icons.hourglass_empty_outlined,
                      title: 'No active check-in',
                      subtitle: 'Find a salon and check in to track your wait',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () => context.go('/customer/home'),
                      child: const Text('Find a salon'),
                    ),
                  ),
                ],
              )
            : queue.when(
                data: (entries) {
                  final activeEntry = checkIn.entry;
                  final nowServing = entries
                      .where((e) => e.status == QueueStatus.serving)
                      .map((e) => e.position)
                      .fold<int>(0, (max, p) => p > max ? p : max);
                  final peopleAhead = (activeEntry.position - 1).clamp(0, 99);

                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: () async {
                      await ref.read(activeCheckInProvider.notifier).refresh();
                      if (businessId != null) {
                        ref.invalidate(queueProvider(businessId));
                      }
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      children: [
                        _QueueHeader(onNotifications: () {
                          context.push('/customer/notifications');
                        }),
                        const SizedBox(height: 20),
                        _ProgressSteps(entry: activeEntry),
                        const SizedBox(height: 20),
                        salon.QueueProgressCard(
                          entry: activeEntry,
                          nowServing: nowServing,
                          peopleAhead: peopleAhead,
                          totalInQueue: entries
                              .where(
                                (e) =>
                                    e.status == QueueStatus.waiting ||
                                    e.status == QueueStatus.serving ||
                                    e.status == QueueStatus.called,
                              )
                              .length,
                        ),
                        const SizedBox(height: 16),
                        business.when(
                          data: (b) {
                            if (b == null) return const SizedBox();
                            return _LocationCard(business: b);
                          },
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                        const SizedBox(height: 16),
                        business.maybeWhen(
                          data: (b) => b == null
                              ? const SizedBox.shrink()
                              : Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _openDirectionsForBusiness(b),
                                        icon: const Icon(
                                            Icons.navigation_rounded),
                                        label: const Text('Directions'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          await ref
                                              .read(activeCheckInProvider
                                                  .notifier)
                                              .cancelCheckIn();
                                          if (context.mounted) {
                                            context.go('/customer/home');
                                          }
                                        },
                                        icon: const Icon(Icons.close_rounded),
                                        label: const Text('Leave Queue'),
                                      ),
                                    ),
                                  ],
                                ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => _showWaitlist(
                            context,
                            entries,
                            activeEntry,
                          ),
                          child: const Text('View Full Waitlist'),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const LoadingView(),
                error: (e, _) => EmptyState(icon: Icons.error, title: '$e'),
              ),
      ),
      bottomNavigationBar:
          checkIn == null ? const CustomerNavBar(currentIndex: -1) : null,
    );
  }

  void _showWaitlist(
    BuildContext context,
    List<QueueEntry> entries,
    QueueEntry myEntry,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Waitlist',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...entries.map(
            (e) => Material(
              color: Colors.transparent,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: e.customerName == 'You'
                      ? AppColors.accent
                      : AppColors.surfaceLight,
                  child: Text(
                    '${e.position}',
                    style: TextStyle(
                      color: e.customerName == 'You'
                          ? AppColors.background
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  e.customerName == 'You' ? 'You' : e.customerName,
                  style: TextStyle(
                    fontWeight: e.customerName == 'You'
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
                subtitle: Text(e.service),
                trailing: Text('~${e.estimatedWaitMinutes} min'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openDirectionsForBusiness(Business b) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${b.latitude},${b.longitude}',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _QueueHeader extends StatelessWidget {
  const _QueueHeader({required this.onNotifications});

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps({required this.entry});

  final QueueEntry entry;

  @override
  Widget build(BuildContext context) {
    const steps = ['In line', 'Arrival', 'Haircut'];
    var activeIndex = 0;
    if (entry.status == QueueStatus.called) activeIndex = 1;
    if (entry.status == QueueStatus.serving) activeIndex = 2;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(height: 2, color: AppColors.divider),
          );
        }
        final stepIndex = i ~/ 2;
        final isActive = stepIndex <= activeIndex;
        return Column(
          children: [
            Container(
              width: isActive ? 12 : 8,
              height: isActive ? 12 : 8,
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              steps[stepIndex],
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color:
                    isActive ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _LocationCard extends ConsumerWidget {
  const _LocationCard({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(business.id);

    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CheckedInBadge(),
          const SizedBox(height: 12),
          Text(
            business.name,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            business.address,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          if (business.landmark != null) ...[
            const SizedBox(height: 4),
            Text(
              business.landmark!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                business.isOpen ? 'Open' : 'Closed',
                style: TextStyle(
                  color: business.isOpen ? AppColors.accent : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (business.closesAt != null)
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
          _ActionRow(
            icon: Icons.navigation_outlined,
            label: 'Get directions',
            onTap: () => _openDirections(business),
          ),
          _ActionRow(
            icon: isFavorite ? Icons.star : Icons.star_outline,
            label: isFavorite ? 'Favorited' : 'Add to favorites',
            onTap: () =>
                ref.read(favoritesProvider.notifier).toggle(business.id),
          ),
          _ActionRow(
              icon: Icons.push_pin_outlined,
              label: 'Set haircut reminders',
              onTap: () {}),
          if (business.phone != null)
            _ActionRow(
                icon: Icons.phone_outlined,
                label: business.phone!,
                onTap: () {}),
          const Divider(color: AppColors.divider),
          _ActionRow(
            icon: Icons.delete_outline,
            label: 'Cancel check-in',
            onTap: () async {
              await ref.read(activeCheckInProvider.notifier).cancelCheckIn();
              if (context.mounted) context.go('/customer/home');
            },
            destructive: true,
          ),
        ],
      ),
    );
  }

  Future<void> _openDirections(Business b) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${b.latitude},${b.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: destructive ? AppColors.error : AppColors.accent,
              size: 22,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: destructive ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep business details for deep links
class BusinessDetailsScreen extends ConsumerWidget {
  const BusinessDetailsScreen({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckInScreen(businessId: businessId);
  }
}

class JoinQueueScreen extends ConsumerStatefulWidget {
  const JoinQueueScreen({super.key, required this.businessId});

  final String businessId;

  @override
  ConsumerState<JoinQueueScreen> createState() => _JoinQueueScreenState();
}

class _JoinQueueScreenState extends ConsumerState<JoinQueueScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _service = 'Haircut';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      final profile = await ref.read(profileProvider.future);
      if (!mounted) return;
      _nameController.text = profile.name;
      _phoneController.text = profile.phone;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessDetailProvider(widget.businessId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Join Queue',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: business.when(
        data: (b) {
          if (b == null) {
            return const EmptyState(
                icon: Icons.store_outlined, title: 'Salon not found');
          }

          const services = [
            'Haircut',
            'Haircut + Beard',
            'Kids Haircut',
            'Hair Color',
            'Styling',
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const salon.SalonAvatar(size: 62),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${b.waitMinutes} min wait · ${b.distanceMiles.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Choose Service',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final service in services)
                    salon.ServiceChip(
                      label: service,
                      selected: _service == service,
                      onTap: () => setState(() => _service = service),
                    ),
                ],
              ),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: '$e'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          child: salon.SalonPrimaryButton(
            label: 'Join Queue',
            icon: Icons.confirmation_number_outlined,
            isLoading: _loading,
            onPressed: _loading ? null : _joinQueue,
          ),
        ),
      ),
    );
  }

  Future<void> _joinQueue() async {
    final phone = _phoneController.text.trim();

    setState(() => _loading = true);
    final entry = await ref.read(queueRepositoryProvider).joinQueue(
          businessId: widget.businessId,
          customerName: 'You',
          service: _service,
          phone: phone.isEmpty ? null : phone,
        );
    await ref.read(activeCheckInProvider.notifier).setCheckIn(
          businessId: widget.businessId,
          entry: entry,
        );
    ref.invalidate(queueProvider(widget.businessId));
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/customer/queue');
  }
}
