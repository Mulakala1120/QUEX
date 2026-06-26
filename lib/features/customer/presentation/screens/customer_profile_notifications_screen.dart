import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/features/customer/presentation/providers/customer_session_provider.dart';
import 'package:quex/features/customer/presentation/widgets/customer_dark_widgets.dart';
import 'package:quex/features/shared/providers/app_providers.dart';
import 'package:quex/ui_kit/quex_ui_kit.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: notifications.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'No notifications yet',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final n = list[index];
              return QxGlassCard(
                radius: 24,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: n.isRead
                            ? AppColors.surfaceLight
                            : AppColors.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: n.isRead
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.accent.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Icon(
                        n.isRead
                            ? Icons.notifications_outlined
                            : Icons.notifications_active,
                        color: n.isRead
                            ? AppColors.textSecondary
                            : AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  n.isRead ? FontWeight.w700 : FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n.body,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat.MMMd().add_jm().format(n.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(icon: Icons.error, title: e.toString()),
      ),
      bottomNavigationBar: const CustomerNavBar(currentIndex: -1),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: profile.when(
          data: (p) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 18),
              if (!auth.isAuthenticated) ...[
                QxGlassCard(
                  radius: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create an account',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'With an account you can favorite salons and more!',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.go('/customer/login'),
                        child: const Text('Sign up'),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/customer/login'),
                          child: const Text('Sign in'),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                QxGlow(
                  blur: 28,
                  child: QxGlassCard(
                    radius: 28,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              AppColors.accent.withValues(alpha: 0.2),
                          child: Text(
                            p.name.isNotEmpty ? p.name[0].toUpperCase() : 'Q',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                auth.phone ?? p.phone,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Favorites - Queue History - Settings',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
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
              ],
              const SizedBox(height: 28),
              const _SectionHeader('PROFILE'),
              const SizedBox(height: 8),
              QxGlassCard(
                radius: 24,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    const _ProfileTile(
                      icon: Icons.favorite_border,
                      title: 'Favorites',
                      onTap: null,
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _ProfileTile(
                      icon: Icons.history_rounded,
                      title: 'Queue History',
                      onTap: () => context.push('/customer/bookings'),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    const _ProfileTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const _SectionHeader('SUPPORT'),
              const SizedBox(height: 8),
              QxGlassCard(
                radius: 24,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    const _ProfileTile(
                      icon: Icons.help_outline,
                      title: 'Support',
                      external: true,
                      onTap: null,
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _ProfileTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () => context.push('/customer/notifications'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (auth.isAuthenticated)
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(activeCheckInProvider.notifier)
                        .cancelCheckIn();
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) context.go('/customer/login');
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              const Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          loading: () => const LoadingView(),
          error: (e, _) => EmptyState(icon: Icons.error, title: e.toString()),
        ),
      ),
      bottomNavigationBar: const CustomerNavBar(currentIndex: 2),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        letterSpacing: 1,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.external = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool external;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(
        external ? Icons.open_in_new : Icons.chevron_right,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
