import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/admin_theme.dart';
import 'package:quex/core/widgets/quex_brand_logo.dart';

class AdminNavItem {
  const AdminNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

const adminNavItems = [
  AdminNavItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    route: '/admin/dashboard',
  ),
  AdminNavItem(
    label: 'Live Queue',
    icon: Icons.people_outline,
    route: '/admin/queue',
  ),
  AdminNavItem(
    label: 'Appointments',
    icon: Icons.calendar_today_outlined,
    route: '/admin/appointments',
  ),
  AdminNavItem(
    label: 'Analytics',
    icon: Icons.bar_chart_outlined,
    route: '/admin/analytics',
  ),
  AdminNavItem(
    label: 'Customers',
    icon: Icons.group_outlined,
    route: '/admin/customers',
  ),
  AdminNavItem(
    label: 'Services',
    icon: Icons.cut_outlined,
    route: '/admin/services',
  ),
  AdminNavItem(
    label: 'Staff',
    icon: Icons.badge_outlined,
    route: '/admin/staff',
  ),
  AdminNavItem(
    label: 'Notifications',
    icon: Icons.notifications_outlined,
    route: '/admin/notifications',
  ),
  AdminNavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    route: '/admin/settings',
  ),
  AdminNavItem(
    label: 'Subscription',
    icon: Icons.card_membership_outlined,
    route: '/admin/subscription',
  ),
];

/// Admin portal shell — purple sidebar brand (mockup dashboard).
class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.currentRoute,
    required this.title,
    required this.child,
    this.actions,
  });

  final String currentRoute;
  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AdminTheme.light,
      child: Scaffold(
        backgroundColor: AdminColors.background,
        drawer: Drawer(
          backgroundColor: AdminColors.sidebar,
          child: _Sidebar(
            currentRoute: currentRoute,
            onNavigate: (route) {
              Navigator.pop(context);
              if (route != currentRoute) context.go(route);
            },
          ),
        ),
        appBar: AppBar(
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          actions: [
            ...?actions,
            IconButton(
              onPressed: () => context.push('/admin/qr'),
              icon: const Icon(Icons.qr_code_2),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: child,
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.currentRoute,
    required this.onNavigate,
  });

  final String currentRoute;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Row(
              children: [
                const QueXBrandLogo(size: 40, style: QueXLogoStyle.admin),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                        children: [
                          TextSpan(text: 'Que'),
                          TextSpan(
                            text: 'X',
                            style: TextStyle(color: AdminColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Business Admin',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: adminNavItems.map((item) {
                final active = currentRoute == item.route ||
                    currentRoute.startsWith('${item.route}/');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color:
                        active ? AdminColors.sidebarActive : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => onNavigate(item.route),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    active ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => context.go('/role-select'),
              icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white70),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AdminColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AdminColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AdminColors.textSecondary,
              fontSize: 13,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                  color: c, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class AdminSectionCard extends StatelessWidget {
  const AdminSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
