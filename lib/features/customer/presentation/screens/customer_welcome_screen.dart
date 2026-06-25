import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/customer_auth_theme.dart';
import 'package:quex/core/widgets/quex_brand_logo.dart';

/// Customer portal entry — light branded welcome (mockup screen 1).
class CustomerWelcomeScreen extends ConsumerWidget {
  const CustomerWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: CustomerAuthTheme.light,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const QueXBrandLogo(
                  size: 72,
                  style: QueXLogoStyle.light,
                  showWordmark: true,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Welcome back! 👋',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: CustomerAuthColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(
                    color: CustomerAuthColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 36),
                _AuthButton(
                  label: 'Continue with Phone',
                  icon: Icons.phone_android_rounded,
                  isPrimary: true,
                  onTap: () => context.push('/customer/login'),
                ),
                const SizedBox(height: 12),
                _AuthButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  onTap: () => _showDemoSnack(context, 'Google sign-in coming soon'),
                ),
                const SizedBox(height: 12),
                _AuthButton(
                  label: 'Continue with Apple',
                  icon: Icons.apple,
                  onTap: () => _showDemoSnack(context, 'Apple sign-in coming soon'),
                ),
                const SizedBox(height: 28),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: CustomerAuthColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _showDemoSnack(context, 'Email login coming soon'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomerAuthColors.salonTint,
                    foregroundColor: CustomerAuthColors.primaryDark,
                    elevation: 0,
                  ),
                  child: const Text('Continue'),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: CustomerAuthColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/customer/login'),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: CustomerAuthColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/role-select'),
                  child: const Text(
                    '← Back to portal selection',
                    style: TextStyle(color: CustomerAuthColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDemoSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomerAuthColors.primary,
          foregroundColor: Colors.white,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: CustomerAuthColors.textPrimary),
      label: Text(
        label,
        style: const TextStyle(
          color: CustomerAuthColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
