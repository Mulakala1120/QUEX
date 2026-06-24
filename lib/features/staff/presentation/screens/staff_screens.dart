import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class StaffLoginScreen extends ConsumerStatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  ConsumerState<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends ConsumerState<StaffLoginScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (_pinController.text == '1234' || _pinController.text.length >= 4) {
      if (mounted) context.go('/staff/dashboard');
    } else {
      setState(() {
        _error = 'Invalid PIN. Demo PIN: 1234';
        _isLoading = false;
      });
      return;
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const QueXAppBar(title: 'Staff Login'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QueXLogo(),
            const SizedBox(height: 24),
            Text(
              'Staff sign in',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your staff PIN to access the queue dashboard',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Staff PIN',
                prefixIcon: Icon(Icons.lock_outline),
                counterText: '',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 8),
            const Text(
              'Demo PIN: 1234',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Sign In',
              isLoading: _isLoading,
              onPressed: _login,
            ),
          ],
        ),
      ),
    );
  }
}

class StaffQueueDashboardScreen extends ConsumerWidget {
  const StaffQueueDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(staffQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Queue Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(staffQueueProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: queueState.when(
        data: (entries) {
          final waiting = entries
              .where((e) =>
                  e.status == QueueStatus.waiting ||
                  e.status == QueueStatus.called ||
                  e.status == QueueStatus.serving)
              .toList();

          if (waiting.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'Queue is empty',
              subtitle: 'Add a walk-in to get started',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(staffQueueProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _NowServingCard(entries: entries),
                const SizedBox(height: 16),
                Text(
                  'Waiting (${waiting.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...waiting.map((e) => _QueueEntryCard(entry: e)),
              ],
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(icon: Icons.error, title: e.toString()),
      ),
      bottomNavigationBar: _StaffActionBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWalkInDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Walk-In', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showWalkInDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    var service = 'Haircut';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Walk-In',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Customer name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: service,
              decoration: const InputDecoration(labelText: 'Service'),
              items: const [
                DropdownMenuItem(value: 'Haircut', child: Text('Haircut')),
                DropdownMenuItem(value: 'Beard Trim', child: Text('Beard Trim')),
                DropdownMenuItem(value: 'Kids Cut', child: Text('Kids Cut')),
              ],
              onChanged: (v) => service = v ?? service,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Add to Queue',
              onPressed: () {
                ref.read(staffQueueProvider.notifier).addWalkIn(
                      nameController.text.isEmpty
                          ? 'Walk-In Guest'
                          : nameController.text,
                      service,
                    );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NowServingCard extends ConsumerWidget {
  const _NowServingCard({required this.entries});

  final List<QueueEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serving = entries.cast<QueueEntry?>().firstWhere(
          (e) =>
              e!.status == QueueStatus.serving ||
              e.status == QueueStatus.called,
          orElse: () => null,
        );
    final next = entries.cast<QueueEntry?>().firstWhere(
          (e) => e!.status == QueueStatus.waiting,
          orElse: () => null,
        );

    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Now Serving',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              serving?.customerName ?? '—',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (serving != null)
              Text(
                serving.service,
                style: const TextStyle(color: Colors.white70),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    onPressed: next != null
                        ? () => ref.read(staffQueueProvider.notifier).callNext()
                        : null,
                    child: const Text('Call Next'),
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

class _QueueEntryCard extends ConsumerWidget {
  const _QueueEntryCard({required this.entry});

  final QueueEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(staffQueueProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    '${entry.position}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        entry.service,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: entry.status.name,
                  color: _statusColor(entry.status),
                ),
              ],
            ),
            if (entry.status == QueueStatus.waiting ||
                entry.status == QueueStatus.called) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => notifier.skip(entry.id),
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => notifier.noShow(entry.id),
                      child: const Text('No Show'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => notifier.complete(entry.id),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.serving:
        return AppColors.success;
      case QueueStatus.called:
        return AppColors.accent;
      case QueueStatus.completed:
        return AppColors.success;
      case QueueStatus.skipped:
      case QueueStatus.noShow:
        return AppColors.error;
      case QueueStatus.waiting:
        return AppColors.textSecondary;
    }
  }
}

class _StaffActionBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Switch Role',
                onPressed: () => context.go('/role-select'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
