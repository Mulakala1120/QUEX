import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class BusinessSignupScreen extends ConsumerStatefulWidget {
  const BusinessSignupScreen({super.key});

  @override
  ConsumerState<BusinessSignupScreen> createState() =>
      _BusinessSignupScreenState();
}

class _BusinessSignupScreenState extends ConsumerState<BusinessSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const QueXAppBar(title: 'Business Signup'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const QueXLogo(),
                const SizedBox(height: 24),
                Text(
                  'Register your business',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start managing walk-in queues digitally',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Business name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.go('/owner/profile-setup');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BusinessProfileSetupScreen extends ConsumerStatefulWidget {
  const BusinessProfileSetupScreen({super.key});

  @override
  ConsumerState<BusinessProfileSetupScreen> createState() =>
      _BusinessProfileSetupScreenState();
}

class _BusinessProfileSetupScreenState
    extends ConsumerState<BusinessProfileSetupScreen> {
  String _category = 'Salon';
  final _addressController = TextEditingController();
  final _hoursController = TextEditingController(text: 'Mon–Sat 9am–7pm');

  @override
  void dispose() {
    _addressController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const QueXAppBar(title: 'Profile Setup'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell customers about your business',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(value: 'Salon', child: Text('Salon')),
                DropdownMenuItem(value: 'Clinic', child: Text('Clinic')),
                DropdownMenuItem(value: 'Spa', child: Text('Spa')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hoursController,
              decoration: const InputDecoration(labelText: 'Hours'),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Save & Continue',
              onPressed: () => context.go('/owner/queue-setup'),
            ),
          ],
        ),
      ),
    );
  }
}

class QueueSetupScreen extends ConsumerStatefulWidget {
  const QueueSetupScreen({super.key});

  @override
  ConsumerState<QueueSetupScreen> createState() => _QueueSetupScreenState();
}

class _QueueSetupScreenState extends ConsumerState<QueueSetupScreen> {
  int _avgServiceMinutes = 15;
  int _maxQueueSize = 20;
  bool _allowRemoteJoin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const QueXAppBar(title: 'Queue Setup'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Configure your queue settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Avg. service time'),
                  subtitle: Text('$_avgServiceMinutes minutes'),
                ),
                Slider(
                  value: _avgServiceMinutes.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  onChanged: (v) =>
                      setState(() => _avgServiceMinutes = v.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Max queue size'),
                  subtitle: Text('$_maxQueueSize customers'),
                ),
                Slider(
                  value: _maxQueueSize.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  onChanged: (v) => setState(() => _maxQueueSize = v.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('Allow remote join'),
              subtitle: const Text('Customers can join via the QueX app'),
              value: _allowRemoteJoin,
              onChanged: (v) => setState(() => _allowRemoteJoin = v),
              activeThumbColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Finish Setup',
            onPressed: () => context.go('/admin/dashboard'),
          ),
        ],
      ),
    );
  }
}

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const qrData = 'https://quex.app/join/biz_1';

    return Scaffold(
      appBar: const QueXAppBar(title: 'Check-In QR Code'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Display this QR code at your front desk',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 220,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'QueX Cuts Downtown',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const Text(
              'Scan to join the queue',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Spacer(),
            SecondaryButton(
              label: 'Share QR Code',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const businessId = 'biz_1';
    final queue = ref.watch(queueProvider(businessId));
    final analytics = ref.watch(analyticsProvider(businessId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(queueProvider(businessId));
            ref.invalidate(analyticsProvider(businessId));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
            children: [
              _OwnerHeader(onQrTap: () => context.push('/owner/qr')),
              const SizedBox(height: 22),
              _OwnerStatusCard(
                completed: analytics.maybeWhen(
                  data: (a) => '${a.completedToday}',
                  orElse: () => '—',
                ),
                avgWait: analytics.maybeWhen(
                  data: (a) => '${a.avgWaitMinutes.toStringAsFixed(0)}m',
                  orElse: () => '—',
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.people_outline,
                      label: 'Live Queue',
                      onTap: () => context.go('/staff/dashboard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.bar_chart,
                      label: 'Analytics',
                      onTap: () => context.push('/owner/analytics'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.qr_code_2,
                      label: 'QR Code',
                      onTap: () => context.push('/owner/qr'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.card_membership,
                      label: 'Plan',
                      onTap: () => context.push('/owner/subscription'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _SectionTitle(
                title: 'Current Queue',
                subtitle: 'Next guests waiting at QueX Cuts Downtown',
              ),
              const SizedBox(height: 12),
              queue.when(
                data: (entries) => Column(
                  children: entries
                      .take(5)
                      .map((e) => _OwnerQueueRow(entry: e))
                      .toList(),
                ),
                loading: () => const LoadingView(),
                error: (e, _) => Text(e.toString()),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _OwnerNav(currentIndex: 0),
    );
  }
}

class _OwnerHeader extends StatelessWidget {
  const _OwnerHeader({required this.onQrTap});

  final VoidCallback onQrTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const QueXLogo(size: 46),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Dashboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manage queues in real time',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onQrTap,
          icon: const Icon(Icons.qr_code_2),
          color: AppColors.accent,
        ),
      ],
    );
  }
}

class _OwnerStatusCard extends StatelessWidget {
  const _OwnerStatusCard({
    required this.completed,
    required this.avgWait,
  });

  final String completed;
  final String avgWait;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QueX Cuts Downtown',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Open now - 4 guests waiting',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              StatusChip(label: 'LIVE', color: AppColors.accent),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _DashStat(label: 'Completed', value: completed)),
              const SizedBox(width: 12),
              Expanded(child: _DashStat(label: 'Avg Wait', value: avgWait)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

class _OwnerQueueRow extends StatelessWidget {
  const _OwnerQueueRow({required this.entry});

  final QueueEntry entry;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.accent.withValues(alpha: 0.14),
            child: Text(
              '${entry.position}',
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
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
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _DashStat extends StatelessWidget {
  const _DashStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.accent, size: 30),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerNav extends StatelessWidget {
  const _OwnerNav({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        switch (i) {
          case 0:
            context.go('/owner/dashboard');
          case 1:
            context.push('/owner/analytics');
          case 2:
            context.push('/owner/subscription');
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), label: 'Analytics'),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_membership),
          label: 'Plan',
        ),
      ],
    );
  }
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider('biz_1'));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: analytics.when(
          data: (a) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
            children: [
              const _AnalyticsHeader(),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Total Customers',
                      value: '${a.totalCustomers}',
                      icon: Icons.people,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Avg Wait',
                      value: '${a.avgWaitMinutes.toStringAsFixed(1)}m',
                      icon: Icons.timer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Completed Today',
                      value: '${a.completedToday}',
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'No Shows',
                      value: '${a.noShows}',
                      icon: Icons.person_off_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SurfaceCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Trend',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Peak hour: ${a.peakHour}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(a.weeklyTrend.length, (i) {
                          final val = a.weeklyTrend[i];
                          final maxVal = a.weeklyTrend.reduce(
                            (x, y) => x > y ? x : y,
                          );
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: (val / maxVal) * 80,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const LoadingView(),
          error: (e, _) => EmptyState(icon: Icons.error, title: e.toString()),
        ),
      ),
    );
  }
}

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        QueXLogo(size: 46),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Today\'s wait-time performance',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        StatusChip(label: 'TODAY', color: AppColors.accent),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(subscriptionPlansProvider);

    return Scaffold(
      appBar: const QueXAppBar(title: 'Subscription'),
      body: plans.when(
        data: (list) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final plan = list[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: plan.isCurrent ? AppColors.primary : AppColors.divider,
                  width: plan.isCurrent ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (plan.isCurrent) ...[
                          const SizedBox(width: 8),
                          const StatusChip(
                            label: 'Current',
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${plan.price.toStringAsFixed(0)}/mo',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...plan.features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check,
                                size: 18, color: AppColors.success),
                            const SizedBox(width: 8),
                            Text(f),
                          ],
                        ),
                      ),
                    ),
                    if (!plan.isCurrent) ...[
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Upgrade',
                        onPressed: () {},
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(icon: Icons.error, title: e.toString()),
      ),
    );
  }
}
