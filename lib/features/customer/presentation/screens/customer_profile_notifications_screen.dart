import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/features/customer/presentation/widgets/customer_nav_bar.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: const QueXAppBar(title: 'Notifications'),
      body: notifications.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'No notifications yet',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final n = list[index];
              return Card(
                color: n.isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.04),
                child: ListTile(
                  leading: Icon(
                    n.isRead
                        ? Icons.notifications_outlined
                        : Icons.notifications_active,
                    color: n.isRead
                        ? AppColors.textSecondary
                        : AppColors.primary,
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight:
                          n.isRead ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(n.body),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.MMMd().add_jm().format(n.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(icon: Icons.error, title: e.toString()),
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: const QueXAppBar(title: 'Profile', showBack: false),
      body: profile.when(
        data: (p) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : 'G',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    p.phone,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _ProfileTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => context.push('/customer/notifications'),
            ),
            _ProfileTile(
              icon: Icons.history,
              title: 'Visit History',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.logout,
              title: 'Sign Out',
              color: AppColors.error,
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go('/role-select');
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/role-select'),
              child: const Text('Switch App Role'),
            ),
          ],
        ),
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(icon: Icons.error, title: e.toString()),
      ),
      bottomNavigationBar: const CustomerNavBar(currentIndex: 3),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(title, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
