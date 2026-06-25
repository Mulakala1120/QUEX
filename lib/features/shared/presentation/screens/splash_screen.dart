import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/theme/admin_theme.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/quex_brand_logo.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _goNext());
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final auth = ref.read(authStateProvider);
    if (auth.isAuthenticated) {
      context.go('/customer/categories');
    } else {
      context.go('/role-select');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const QueXBrandLogo(size: 88, style: QueXLogoStyle.dark, showWordmark: true),
            const SizedBox(height: 8),
            Text(
              AppConstants.tagline,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const QueXBrandLogo(size: 56, style: QueXLogoStyle.dark, showWordmark: true),
              const SizedBox(height: 8),
              const Text(
                AppConstants.tagline,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              const Text(
                'Choose your portal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Customer and Business Admin are separate experiences',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 28),
              _PortalCard(
                icon: Icons.person_outline,
                title: 'Customer Portal',
                subtitle: 'Find salons & clinics, see live wait times, join queues',
                accent: AppColors.accent,
                onTap: () {
                  ref.read(appRoleProvider.notifier).state = AppRole.customer;
                  ref.read(authStateProvider.notifier).resetLoginFlow();
                  final auth = ref.read(authStateProvider);
                  if (auth.isAuthenticated) {
                    context.go('/customer/categories');
                  } else {
                    context.go('/customer/welcome');
                  }
                },
              ),
              const SizedBox(height: 16),
              _PortalCard(
                icon: Icons.dashboard_outlined,
                title: 'Business Admin',
                subtitle: 'Manage queue, staff, analytics & subscriptions',
                accent: AdminColors.primary,
                onTap: () {
                  ref.read(appRoleProvider.notifier).state =
                      AppRole.businessOwner;
                  context.go('/admin/login');
                },
              ),
              const SizedBox(height: 16),
              _PortalCard(
                icon: Icons.badge_outlined,
                title: 'Staff / Reception',
                subtitle: 'Run the queue — call next, skip, complete',
                accent: AppColors.clinicBlue,
                onTap: () {
                  ref.read(appRoleProvider.notifier).state = AppRole.staff;
                  context.go('/staff/login');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortalCard extends StatelessWidget {
  const _PortalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accent.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
