import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/quex_brand_logo.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

enum _LoginStage { options, phone, otp }

class CustomerLoginScreen extends ConsumerStatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  ConsumerState<CustomerLoginScreen> createState() =>
      _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends ConsumerState<CustomerLoginScreen> {
  final _phoneController = TextEditingController(text: '+91 ');
  final _otpController = TextEditingController();
  _LoginStage _stage = _LoginStage.options;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    await ref.read(authStateProvider.notifier).sendOtp(_phoneController.text);
    if (mounted) setState(() => _stage = _LoginStage.otp);
  }

  Future<void> _verifyOtp(String otp) async {
    final success = await ref.read(authStateProvider.notifier).verifyOtp(otp);
    if (success && mounted) context.go('/customer/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _glow(260, AppColors.accent.withValues(alpha: 0.16)),
          ),
          Positioned(
            bottom: -140,
            left: -90,
            child: _glow(280, AppColors.accent.withValues(alpha: 0.08)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_stage != _LoginStage.options)
                    IconButton(
                      onPressed: () {
                        ref.read(authStateProvider.notifier).resetLoginFlow();
                        setState(() => _stage = _stage == _LoginStage.otp
                            ? _LoginStage.phone
                            : _LoginStage.options);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  const Spacer(),
                  const QueXBrandLogo(
                    size: 72,
                    style: QueXLogoStyle.dark,
                    showWordmark: true,
                  ),
                  const SizedBox(height: 28),
                  if (_stage == _LoginStage.options) ..._buildOptions(auth),
                  if (_stage == _LoginStage.phone) ..._buildPhone(auth),
                  if (_stage == _LoginStage.otp) ..._buildOtp(auth),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptions(AuthState auth) {
    return [
      const Text(
        'Welcome Back',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Sign in to continue',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
      ),
      const SizedBox(height: 32),
      _AuthButton(
        icon: Icons.phone_outlined,
        label: 'Continue with Phone',
        filled: true,
        onTap: () => setState(() => _stage = _LoginStage.phone),
      ),
      const SizedBox(height: 14),
      _AuthButton(
        icon: Icons.g_mobiledata,
        label: 'Continue with Google',
        onTap: () => context.go('/customer/home'),
      ),
      const SizedBox(height: 14),
      _AuthButton(
        icon: Icons.person_outline,
        label: 'Guest Mode',
        onTap: () => context.go('/customer/home'),
      ),
    ];
  }

  List<Widget> _buildPhone(AuthState auth) {
    return [
      const Text(
        'Enter your phone',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        "We'll text you a one-time code to sign in",
        style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
      ),
      const SizedBox(height: 28),
      TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s()-]')),
        ],
        decoration: const InputDecoration(
          hintText: '+91 98765 43210',
          prefixIcon: Icon(Icons.phone_outlined, color: AppColors.accent),
        ),
      ),
      const SizedBox(height: 24),
      _PrimaryCta(
        label: 'Send Code',
        loading: auth.isLoading,
        onTap: _sendOtp,
      ),
    ];
  }

  List<Widget> _buildOtp(AuthState auth) {
    final pinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(14),
      ),
    );

    return [
      const Text(
        'Verification',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Enter the 6-digit code sent to ${auth.phone ?? "your phone"}',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
      ),
      const SizedBox(height: 28),
      Pinput(
        controller: _otpController,
        length: AppConstants.otpLength,
        autofocus: true,
        defaultPinTheme: pinTheme,
        focusedPinTheme: pinTheme.copyWith(
          decoration: pinTheme.decoration!.copyWith(
            border: Border.all(color: AppColors.accent, width: 2),
          ),
        ),
        onCompleted: _verifyOtp,
      ),
      const SizedBox(height: 16),
      const Center(
        child: Text(
          'Demo OTP: ${AppConstants.demoOtp}',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
      if (auth.error != null) ...[
        const SizedBox(height: 12),
        Center(
          child: Text(
            auth.error!,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
      const SizedBox(height: 24),
      _PrimaryCta(
        label: 'Verify & Continue',
        loading: auth.isLoading,
        onTap: () => _verifyOtp(_otpController.text),
      ),
    ];
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, AppColors.background.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: filled
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: filled ? AppColors.background : AppColors.textPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: filled ? AppColors.background : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.background,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
