import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/theme/admin_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/core/widgets/quex_brand_logo.dart';
import 'package:quex/features/admin/presentation/widgets/admin_shell.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

// ─── Admin Login ───────────────────────────────────────────────────────────

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailController = TextEditingController(text: 'owner@quex.app');
  final _passwordController = TextEditingController(text: 'demo1234');
  bool _loading = false;
  bool _remember = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _loading = false);
      context.go('/admin/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AdminTheme.light,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AdminColors.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        const QueXBrandLogo(
                          size: 64,
                          style: QueXLogoStyle.admin,
                          showWordmark: true,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Business Admin',
                          style: TextStyle(
                            color: AdminColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AdminColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AdminColors.divider),
                            boxShadow: [
                              BoxShadow(
                                color: AdminColors.primary.withValues(alpha: 0.06),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone or Email',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _remember,
                                    onChanged: (v) =>
                                        setState(() => _remember = v ?? true),
                                  ),
                                  const Text('Remember me'),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('Forgot Password?'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _login,
                                  child: _loading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Login'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => context.go('/owner/signup'),
                                child: const Text('Register new business'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => context.go('/role-select'),
                          child: const Text('← Back to portal selection'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard ─────────────────────────────────────────────────────────────

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const businessId = 'biz_1';
    final queue = ref.watch(queueProvider(businessId));
    final analytics = ref.watch(analyticsProvider(businessId));
    final waiting = queue.maybeWhen(
      data: (e) => e.where((x) => x.status == QueueStatus.waiting).length,
      orElse: () => 0,
    );

    return AdminShell(
      currentRoute: '/admin/dashboard',
      title: 'Dashboard',
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(queueProvider(businessId));
          ref.invalidate(analyticsProvider(businessId));
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _greeting(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              _today(),
              style: const TextStyle(color: AdminColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AdminStatCard(
                    label: 'Live Queue',
                    value: '$waiting',
                    icon: Icons.people_outline,
                    color: AdminColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminStatCard(
                    label: 'Est. Wait',
                    value: analytics.maybeWhen(
                      data: (a) => '${a.avgWaitMinutes.toStringAsFixed(0)}m',
                      orElse: () => '—',
                    ),
                    icon: Icons.timer_outlined,
                    color: AdminColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminStatCard(
                    label: 'Served Today',
                    value: analytics.maybeWhen(
                      data: (a) => '${a.completedToday}',
                      orElse: () => '—',
                    ),
                    icon: Icons.check_circle_outline,
                    color: AdminColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminStatCard(
                    label: 'Walk-ins',
                    value: analytics.maybeWhen(
                      data: (a) => '${(a.completedToday * 0.4).round()}',
                      orElse: () => '—',
                    ),
                    icon: Icons.directions_walk_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AdminSectionCard(
              title: 'Queue Trend',
              child: analytics.maybeWhen(
                data: (a) => SizedBox(
                  height: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(a.weeklyTrend.length, (i) {
                      final val = a.weeklyTrend[i];
                      final maxVal =
                          a.weeklyTrend.reduce((x, y) => x > y ? x : y);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: (val / maxVal) * 70,
                                decoration: BoxDecoration(
                                  color: AdminColors.primary
                                      .withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                orElse: () => const LoadingView(),
              ),
            ),
            const SizedBox(height: 16),
            AdminSectionCard(
              title: 'Peak Hours',
              child: analytics.maybeWhen(
                data: (a) => Column(
                  children: [
                    _PeakRow(hour: '10 AM', level: 'High', color: AdminColors.error),
                    _PeakRow(hour: '2 PM', level: 'Medium', color: AdminColors.warning),
                    _PeakRow(
                      hour: a.peakHour,
                      level: 'Peak',
                      color: AdminColors.primary,
                    ),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
            AdminSectionCard(
              title: 'Quick Actions',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickChip(
                    label: 'Add Walk-in',
                    onTap: () => context.go('/admin/queue'),
                  ),
                  _QuickChip(
                    label: 'Add Appointment',
                    onTap: () => context.go('/admin/appointments'),
                  ),
                  _QuickChip(
                    label: 'View QR',
                    onTap: () => context.push('/admin/qr'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AdminSectionCard(
              title: 'Recent Activity',
              child: queue.maybeWhen(
                data: (entries) => Column(
                  children: entries.take(4).map((e) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                            AdminColors.primary.withValues(alpha: 0.1),
                        child: Text('${e.position}'),
                      ),
                      title: Text(e.customerName),
                      subtitle: Text(e.service),
                      trailing: Text(
                        '${e.estimatedWaitMinutes}m',
                        style: const TextStyle(
                          color: AdminColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                orElse: () => const LoadingView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning, John!';
    if (h < 17) return 'Good Afternoon, John!';
    return 'Good Evening, John!';
  }

  String _today() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

class _PeakRow extends StatelessWidget {
  const _PeakRow({
    required this.hour,
    required this.level,
    required this.color,
  });

  final String hour;
  final String level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(hour, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: level == 'High' ? 0.9 : level == 'Medium' ? 0.6 : 0.75,
              backgroundColor: AdminColors.divider,
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(level, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AdminColors.primary.withValues(alpha: 0.1),
      labelStyle: const TextStyle(
        color: AdminColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Live Queue ────────────────────────────────────────────────────────────

class AdminLiveQueueScreen extends ConsumerWidget {
  const AdminLiveQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const businessId = 'biz_1';
    final queue = ref.watch(queueProvider(businessId));

    return AdminShell(
      currentRoute: '/admin/queue',
      title: 'Live Queue',
      child: queue.when(
        data: (entries) {
          final waiting = entries
              .where((e) =>
                  e.status == QueueStatus.waiting ||
                  e.status == QueueStatus.called)
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        label: 'In Queue',
                        value: '${waiting.length}',
                        icon: Icons.hourglass_top,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminStatCard(
                        label: 'Est. Next',
                        value: waiting.isNotEmpty
                            ? '${waiting.first.estimatedWaitMinutes}m'
                            : '—',
                        icon: Icons.timer,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: waiting.length,
                  itemBuilder: (context, i) {
                    final e = waiting[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AdminColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            '${e.position}',
                            style: const TextStyle(
                              color: AdminColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(e.customerName),
                        subtitle: Text(e.service),
                        trailing: StatusChip(
                          label: e.status == QueueStatus.called
                              ? 'Est. Next'
                              : 'Waiting',
                          color: e.status == QueueStatus.called
                              ? AdminColors.success
                              : AdminColors.warning,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Add Walk-in'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.go('/staff/dashboard'),
                        child: const Text('Call Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

// ─── Analytics ─────────────────────────────────────────────────────────────

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider('biz_1'));

    return AdminShell(
      currentRoute: '/admin/analytics',
      title: 'Analytics',
      child: analytics.when(
        data: (a) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: AdminStatCard(
                    label: 'Total Customers',
                    value: '${a.totalCustomers}',
                    icon: Icons.people,
                    subtitle: '+12% vs last week',
                    color: AdminColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminStatCard(
                    label: 'Avg Wait',
                    value: '${a.avgWaitMinutes.toStringAsFixed(1)}m',
                    icon: Icons.timer,
                    subtitle: '-8% vs last week',
                    color: AdminColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdminSectionCard(
              title: 'Customers Over Time',
              child: SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(a.weeklyTrend.length, (i) {
                    final val = a.weeklyTrend[i];
                    final maxVal =
                        a.weeklyTrend.reduce((x, y) => x > y ? x : y);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          height: (val / maxVal) * 100,
                          decoration: BoxDecoration(
                            color: AdminColors.primaryLight
                                .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AdminSectionCard(
              title: 'Top Services',
              child: Column(
                children: [
                  _ServiceRow(name: 'Haircut', count: 42),
                  _ServiceRow(name: 'Consultation', count: 28),
                  _ServiceRow(name: 'Styling', count: 19),
                ],
              ),
            ),
          ],
        ),
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.name, required this.count});

  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text('$count', style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── Placeholder pages ─────────────────────────────────────────────────────

class AdminPlaceholderScreen extends StatelessWidget {
  const AdminPlaceholderScreen({
    super.key,
    required this.route,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final String route;
  final String title;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: route,
      title: title,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AdminColors.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle ?? 'Coming in next release with quex-api backend.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AdminColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Settings ──────────────────────────────────────────────────────────────

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _nameController = TextEditingController(text: 'Looks Salon Banjara Hills');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _addressController =
      TextEditingController(text: 'Road No. 12, Banjara Hills, Hyderabad');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/settings',
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AdminSectionCard(
            title: 'Business Profile',
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Business Name'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: 'Salon',
                  decoration: const InputDecoration(labelText: 'Business Type'),
                  items: const [
                    DropdownMenuItem(value: 'Salon', child: Text('Salon')),
                    DropdownMenuItem(value: 'Clinic', child: Text('Clinic')),
                    DropdownMenuItem(value: 'Hospital', child: Text('Hospital')),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile saved (demo)')),
                      );
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subscription ──────────────────────────────────────────────────────────

class AdminSubscriptionScreen extends ConsumerWidget {
  const AdminSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(subscriptionPlansProvider);

    return AdminShell(
      currentRoute: '/admin/subscription',
      title: 'Subscription',
      child: plans.when(
        data: (list) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final plan = list[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
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
                            color: AdminColors.primary,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '₹${(plan.price * 83).toStringAsFixed(0)}/mo',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...plan.features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check,
                                size: 16, color: AdminColors.success),
                            const SizedBox(width: 8),
                            Text(f),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

// ─── QR ────────────────────────────────────────────────────────────────────

class AdminQrScreen extends StatelessWidget {
  const AdminQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/dashboard',
      title: 'QR Code',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Looks Salon Banjara Hills',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Customers scan to join your queue',
                style: TextStyle(color: AdminColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AdminColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AdminColors.divider),
                ),
                child: QrImageView(
                  data: 'https://quex.app/join/biz_1',
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: const Text('Share QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
