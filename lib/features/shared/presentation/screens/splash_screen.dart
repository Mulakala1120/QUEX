import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/theme/admin_theme.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/qx_monogram.dart';
import 'package:quex/core/widgets/quex_brand_logo.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _pulse;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _wordFade;
  late final Animation<double> _wordSlide;
  late final Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _wordFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
    );
    _wordSlide = Tween<double>(begin: 26, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _goNext());
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 2900));
    if (!mounted) return;
    context.go('/customer/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Pulsing radial green glow behind the logo.
          Center(
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                final t = _pulse.value;
                return Container(
                  width: 220 + t * 90,
                  height: 220 + t * 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.16 + t * 0.10),
                        AppColors.background.withValues(alpha: 0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const QxMonogram(size: 150),
                  ),
                ),
                const SizedBox(height: 26),
                FadeTransition(
                  opacity: _wordFade,
                  child: AnimatedBuilder(
                    animation: _wordSlide,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _wordSlide.value),
                      child: child,
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          TextSpan(text: 'Que'),
                          TextSpan(
                            text: 'X',
                            style: TextStyle(color: AppColors.accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: _taglineFade,
                  child: const Text(
                    'Your Time Matters',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom loader + brand line.
          Positioned(
            left: 0,
            right: 0,
            bottom: 54,
            child: FadeTransition(
              opacity: _taglineFade,
              child: Column(
                children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      color: AppColors.accent.withValues(alpha: 0.8),
                      strokeWidth: 2.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'QueX',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              const QueXBrandLogo(
                  size: 56, style: QueXLogoStyle.dark, showWordmark: true),
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
                'Customer and Business are separate experiences',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 28),
              _PortalCard(
                icon: Icons.person_outline,
                title: 'Customer',
                subtitle: 'Find salons & hospitals, check-in, track live queue',
                accent: AppColors.accent,
                onTap: () {
                  ref.read(appRoleProvider.notifier).state = AppRole.customer;
                  context.go('/customer/login');
                },
              ),
              const SizedBox(height: 16),
              _PortalCard(
                icon: Icons.dashboard_outlined,
                title: 'Business',
                subtitle: 'Dashboard, live queue, appointments, analytics',
                accent: AdminColors.primary,
                onTap: () {
                  ref.read(appRoleProvider.notifier).state =
                      AppRole.businessOwner;
                  context.go('/admin/login');
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
