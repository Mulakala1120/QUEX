import 'package:flutter/material.dart';
import 'package:quex/core/theme/admin_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/features/admin/data/admin_dummy_data.dart';
import 'package:quex/features/admin/presentation/widgets/admin_shell.dart';

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/appointments',
      title: 'Appointments',
      actions: [
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('New'),
        ),
      ],
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: AdminDummyData.appointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final a = AdminDummyData.appointments[i];
          final confirmed = a.status == 'Confirmed';
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AdminColors.primary.withValues(alpha: 0.12),
                child: Text(
                  a.time.split(' ').first,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.primary,
                  ),
                ),
              ),
              title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(a.service),
              trailing: StatusChip(
                label: a.status,
                color: confirmed ? AdminColors.success : AdminColors.warning,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdminCustomersScreen extends StatelessWidget {
  const AdminCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/customers',
      title: 'Customers',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search customers',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: AdminDummyData.customers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = AdminDummyData.customers[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AdminColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        c.name[0],
                        style: const TextStyle(
                          color: AdminColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${c.visits} visits · Last: ${c.lastVisit}'),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_outlined),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AdminServicesScreen extends StatelessWidget {
  const AdminServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/services',
      title: 'Services',
      actions: [
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ],
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: AdminDummyData.services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final s = AdminDummyData.services[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          '${s.duration} · ${s.price}',
                          style: const TextStyle(color: AdminColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: s.active,
                    onChanged: (_) {},
                    activeTrackColor: AdminColors.primary.withValues(alpha: 0.4),
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AdminColors.primary;
                      }
                      return null;
                    }),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdminStaffScreen extends StatelessWidget {
  const AdminStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/staff',
      title: 'Staff',
      actions: [
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Add'),
        ),
      ],
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: AdminDummyData.staff.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final s = AdminDummyData.staff[i];
          final active = s.status == 'Active';
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AdminColors.primary.withValues(alpha: 0.12),
                child: const Icon(Icons.person, color: AdminColors.primary),
              ),
              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${s.role} · ${s.services}'),
              trailing: StatusChip(
                label: s.status,
                color: active ? AdminColors.success : AdminColors.warning,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  int _tab = 0;
  static const _tabs = ['All', 'System', 'Queue', 'Promotions'];

  @override
  Widget build(BuildContext context) {
    final items = AdminDummyData.notifications.where((n) {
      if (_tab == 0) return true;
      return n.category == _tabs[_tab];
    }).toList();

    return AdminShell(
      currentRoute: '/admin/notifications',
      title: 'Notifications',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = _tab == i;
                return FilterChip(
                  label: Text(_tabs[i]),
                  selected: selected,
                  onSelected: (_) => setState(() => _tab = i),
                  selectedColor: AdminColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AdminColors.primary,
                );
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = items[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    n.category == 'Queue'
                        ? Icons.people_outline
                        : n.category == 'System'
                            ? Icons.info_outline
                            : Icons.local_offer_outlined,
                    color: AdminColors.primary,
                  ),
                  title: Text(n.message),
                  subtitle: Text(n.time),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
