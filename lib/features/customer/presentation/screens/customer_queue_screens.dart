import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/di/providers.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/core/widgets/quex_widgets.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class BusinessDetailsScreen extends ConsumerStatefulWidget {
  const BusinessDetailsScreen({super.key, required this.businessId});

  final String businessId;

  @override
  ConsumerState<BusinessDetailsScreen> createState() =>
      _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  String? _selectedService;

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessDetailProvider(widget.businessId));

    return business.when(
      data: (b) {
        if (b == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.store_outlined,
              title: 'Salon not found',
            ),
          );
        }

        _selectedService ??=
            b.services.isNotEmpty ? b.services.first : 'Haircut';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      SalonImagePlaceholder(
                        height: 220,
                        borderRadius: 0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: AppColors.warning,
                          ),
                          Text(
                            ' ${b.rating}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.place_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          Text(
                            ' ${b.distanceDisplay}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          OpenStatusBadge(isOpen: b.isOpen),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (b.isOpen)
                        WaitTimeBadge(
                          minutes: b.waitMinutes,
                          large: true,
                        ),
                      const SizedBox(height: 24),
                      const Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: b.services
                            .map(
                              (s) => ServiceChip(
                                label: s,
                                selected: _selectedService == s,
                                onTap: () =>
                                    setState(() => _selectedService = s),
                              ),
                            )
                            .toList(),
                      ),
                      if (b.description != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
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
                      if (b.hours != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              b.hours!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
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
              child: QueXPrimaryButton(
                label: 'Join Queue',
                icon: Icons.people_alt_rounded,
                onPressed: b.isOpen
                    ? () => context.push(
                          '/customer/join-queue/${widget.businessId}',
                        )
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
          title: 'Error loading salon',
          subtitle: e.toString(),
        ),
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
  int _step = 0;
  final _nameController = TextEditingController(text: 'Guest User');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  String? _selectedService;
  bool _isLoading = false;
  int? _tokenNumber;
  int? _position;
  int? _peopleAhead;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _joinQueue(Business business) async {
    setState(() => _isLoading = true);
    await ref.read(queueRepositoryProvider).joinQueue(
          businessId: widget.businessId,
          customerName: _nameController.text.trim(),
          service: _selectedService!,
        );
    ref.invalidate(queueProvider(widget.businessId));

    final queue = await ref.read(queueRepositoryProvider).getQueueForBusiness(
          widget.businessId,
        );
    QueueEntry? myEntry;
    for (final e in queue) {
      if (e.customerName == _nameController.text.trim() ||
          e.customerName == 'You') {
        myEntry = e;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _step = 2;
        _tokenNumber = myEntry?.position ?? queue.length;
        _position = myEntry?.position ?? queue.length;
        _peopleAhead = (_position ?? 1) - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessDetailProvider(widget.businessId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_stepTitle),
        leading: _step < 2
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (_step > 0) {
                    setState(() => _step--);
                  } else {
                    context.pop();
                  }
                },
              )
            : null,
      ),
      body: business.when(
        data: (b) {
          if (b == null) {
            return const EmptyState(icon: Icons.error, title: 'Not found');
          }
          _selectedService ??=
              b.services.isNotEmpty ? b.services.first : 'Haircut';

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _StepIndicator(currentStep: _step),
                const SizedBox(height: 28),
                Expanded(child: _buildStepContent(b)),
              ],
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(icon: Icons.error, title: e.toString()),
      ),
    );
  }

  String get _stepTitle {
    switch (_step) {
      case 0:
        return 'Your Details';
      case 1:
        return 'Confirm Queue';
      case 2:
        return 'You\'re In!';
      default:
        return 'Join Queue';
    }
  }

  Widget _buildStepContent(Business business) {
    switch (_step) {
      case 0:
        return _buildStep1(business);
      case 1:
        return _buildStep2(business);
      case 2:
        return _buildStep3(business);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1(Business business) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          business.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter your details to join the queue',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s()-]')),
          ],
          decoration: const InputDecoration(
            labelText: 'Phone',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Select Service',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: business.services
              .map(
                (s) => ServiceChip(
                  label: s,
                  selected: _selectedService == s,
                  onTap: () => setState(() => _selectedService = s),
                ),
              )
              .toList(),
        ),
        const Spacer(),
        QueXPrimaryButton(
          label: 'Continue',
          onPressed: () => setState(() => _step = 1),
        ),
      ],
    );
  }

  Widget _buildStep2(Business business) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QueXCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Queue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _ConfirmRow('Salon', business.name),
              _ConfirmRow('Name', _nameController.text),
              _ConfirmRow('Phone', _phoneController.text),
              _ConfirmRow('Service', _selectedService ?? ''),
              const Divider(height: 28),
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Estimated Wait: ~${business.waitMinutes} min',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        QueXPrimaryButton(
          label: 'Join Queue',
          isLoading: _isLoading,
          icon: Icons.check_circle_outline_rounded,
          onPressed: () => _joinQueue(business),
        ),
      ],
    );
  }

  Widget _buildStep3(Business business) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 56,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Token Created!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          business.name,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        CircularQueueProgress(
          progress: 0.15,
          tokenNumber: _tokenNumber ?? 0,
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            QueueStatTile(
              label: 'Position',
              value: '#${_position ?? 0}',
              highlight: true,
            ),
            const SizedBox(width: 10),
            QueueStatTile(
              label: 'People Ahead',
              value: '${_peopleAhead ?? 0}',
            ),
            const SizedBox(width: 10),
            QueueStatTile(
              label: 'Est. Wait',
              value: '${business.waitMinutes}m',
            ),
          ],
        ),
        const Spacer(),
        QueXPrimaryButton(
          label: 'Track My Queue',
          onPressed: () => context.go('/customer/queue'),
        ),
        const SizedBox(height: 12),
        QueXSecondaryButton(
          label: 'Back to Home',
          onPressed: () => context.go('/customer/home'),
        ),
      ],
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.card,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Queue'),
        automaticallyImplyLeading: true,
      ),
      body: queue.when(
        data: (entries) {
          QueueEntry? myEntry;
          for (final e in entries) {
            if (e.customerName == 'You' || e.customerName == 'Guest User') {
              myEntry = e;
              break;
            }
          }

          if (myEntry == null) {
            return EmptyState(
              icon: Icons.hourglass_empty_outlined,
              title: 'No active queue',
              subtitle: 'Join a salon to track your spot',
            );
          }

          final activeEntry = myEntry;
          final peopleAhead = activeEntry.position - 1;
          final nowServing = entries
              .where((e) => e.status == QueueStatus.serving)
              .map((e) => e.position)
              .firstOrNull;
          final progress = entries.isEmpty
              ? 0.0
              : 1 - (activeEntry.position / entries.length);

          return RefreshIndicator(
            color: AppColors.primary,
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
                const SizedBox(height: 28),
                Center(
                  child: CircularQueueProgress(
                    progress: progress,
                    tokenNumber: activeEntry.position,
                    size: 220,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    QueueStatTile(
                      label: 'Position',
                      value: '#${activeEntry.position}',
                      highlight: true,
                    ),
                    const SizedBox(width: 10),
                    QueueStatTile(
                      label: 'People Ahead',
                      value: '$peopleAhead',
                    ),
                    const SizedBox(width: 10),
                    QueueStatTile(
                      label: 'Est. Wait',
                      value: '${activeEntry.estimatedWaitMinutes}m',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                QueXCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.record_voice_over_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Now Serving',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              nowServing != null
                                  ? 'Token #$nowServing'
                                  : 'Starting soon',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Live',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                QueXCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.content_cut_rounded,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Service',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              activeEntry.service,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      WaitTimeBadge(
                        minutes: activeEntry.estimatedWaitMinutes,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                QueXPrimaryButton(
                  label: 'Directions',
                  icon: Icons.directions_rounded,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                QueXSecondaryButton(
                  label: 'Leave Queue',
                  icon: Icons.exit_to_app_rounded,
                  onPressed: () => context.go('/customer/home'),
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
