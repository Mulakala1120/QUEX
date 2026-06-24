import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/di/providers.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/customer/presentation/widgets/customer_nav_bar.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class BusinessDetailsScreen extends ConsumerWidget {
  const BusinessDetailsScreen({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessDetailProvider(businessId));

    return business.when(
      data: (b) {
        if (b == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.store_outlined,
              title: 'Business not found',
            ),
          );
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    b.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  background: Container(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    child: Icon(
                      b.category == 'Clinic'
                          ? Icons.local_hospital
                          : Icons.content_cut,
                      size: 64,
                      color: AppColors.primary,
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
                          StatusChip(
                            label: b.isOpen ? 'Open' : 'Closed',
                            color: b.isOpen ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          StatusChip(
                            label: b.category,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(Icons.star, '${b.rating} rating'),
                      _InfoRow(Icons.place_outlined, b.address),
                      if (b.phone != null)
                        _InfoRow(Icons.phone_outlined, b.phone!),
                      if (b.hours != null)
                        _InfoRow(Icons.schedule, b.hours!),
                      const SizedBox(height: 16),
                      if (b.isOpen)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined,
                                  color: AppColors.success),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '~${b.waitMinutes} min estimated wait',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${b.queueCount} people in queue',
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
                      const SizedBox(height: 24),
                      Text(
                        'Services',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: b.services
                            .map(
                              (s) => Chip(
                                label: Text(s),
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.08),
                              ),
                            )
                            .toList(),
                      ),
                      if (b.description != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'About',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.description!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
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
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: b.isOpen ? 'Join Queue' : 'Currently Closed',
                onPressed: b.isOpen
                    ? () => context.push('/customer/join-queue/$businessId')
                    : null,
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Error loading business',
          subtitle: e.toString(),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class JoinQueueScreen extends ConsumerStatefulWidget {
  const JoinQueueScreen({super.key, required this.businessId});

  final String businessId;

  @override
  ConsumerState<JoinQueueScreen> createState() => _JoinQueueScreenState();
}

class _JoinQueueScreenState extends ConsumerState<JoinQueueScreen> {
  String? _selectedService;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessDetailProvider(widget.businessId));

    return Scaffold(
      appBar: const QueXAppBar(title: 'Join Queue'),
      body: business.when(
        data: (b) {
          if (b == null) return const EmptyState(icon: Icons.error, title: 'Not found');
          _selectedService ??= b.services.isNotEmpty ? b.services.first : 'General';

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a service to join the queue',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ...b.services.map(
                  (s) => RadioListTile<String>(
                    title: Text(s),
                    value: s,
                    groupValue: _selectedService,
                    onChanged: (v) => setState(() => _selectedService = v),
                    activeColor: AppColors.primary,
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Join Queue',
                  isLoading: _isLoading,
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    await ref.read(queueRepositoryProvider).joinQueue(
                          businessId: widget.businessId,
                          customerName: 'You',
                          service: _selectedService!,
                        );
                    ref.invalidate(queueProvider(widget.businessId));
                    if (mounted) context.go('/customer/queue');
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(icon: Icons.error, title: e.toString()),
      ),
    );
  }
}

class LiveQueueScreen extends ConsumerWidget {
  const LiveQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const businessId = 'biz_1';
    final queue = ref.watch(queueProvider(businessId));
    final business = ref.watch(businessDetailProvider(businessId));

    return Scaffold(
      appBar: const QueXAppBar(title: 'Live Queue', showBack: false),
      body: queue.when(
        data: (entries) {
          QueueEntry? myEntry;
          for (final e in entries) {
            if (e.customerName == 'You') {
              myEntry = e;
              break;
            }
          }
          if (myEntry == null) {
            return const EmptyState(
              icon: Icons.hourglass_empty_outlined,
              title: 'No active queue',
              subtitle: 'Join a salon or clinic to track your spot',
            );
          }

          final activeEntry = myEntry;

          return RefreshIndicator(
            onRefresh: () => ref.refresh(queueProvider(businessId).future),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                business.when(
                  data: (b) => Text(
                    b?.name ?? 'Your Queue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your Position',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '#${activeEntry.position}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '~${activeEntry.estimatedWaitMinutes} min wait',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeEntry.service,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Queue Ahead',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...entries.where((e) => e.position < activeEntry.position).map(
                      (e) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: Text('${e.position}'),
                          ),
                          title: Text(e.customerName),
                          subtitle: Text(e.service),
                          trailing: StatusChip(
                            label: _statusLabel(e.status),
                            color: _statusColor(e.status),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(icon: Icons.error, title: e.toString()),
      ),
      bottomNavigationBar: const CustomerNavBar(currentIndex: 2),
    );
  }

  String _statusLabel(QueueStatus status) => status.name;

  Color _statusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.serving:
        return AppColors.success;
      case QueueStatus.called:
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }
}
