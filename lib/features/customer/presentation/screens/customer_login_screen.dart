import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/quex_widgets.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class CustomerLoginScreen extends ConsumerStatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  ConsumerState<CustomerLoginScreen> createState() =>
      _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends ConsumerState<CustomerLoginScreen> {
  final _phoneController = TextEditingController(text: '+91 ');
  bool _showPhoneFlow = false;
  bool _showOtp = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    await ref.read(authStateProvider.notifier).sendOtp(_phoneController.text);
    if (ref.read(authStateProvider).otpSent) {
      setState(() => _showOtp = true);
    }
  }

  Future<void> _verifyOtp(String otp) async {
    final success = await ref.read(authStateProvider.notifier).verifyOtp(otp);
    if (success && mounted) context.go('/customer/home');
  }

  void _continueAsGuest() {
    context.go('/customer/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    if (_showPhoneFlow) {
      return _buildPhoneFlow(auth);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const QueXBrandLogo(size: 88, showWordmark: true),
              const SizedBox(height: 12),
              const Text(
                AppConstants.tagline,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(flex: 3),
              QueXPrimaryButton(
                label: 'Continue with Phone',
                icon: Icons.phone_android_rounded,
                onPressed: () => setState(() => _showPhoneFlow = true),
              ),
              const SizedBox(height: 14),
              QueXSecondaryButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                onPressed: () => context.go('/customer/home'),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: _continueAsGuest,
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneFlow(AuthState auth) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_showOtp) {
              setState(() => _showOtp = false);
            } else {
              setState(() => _showPhoneFlow = false);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _showOtp ? 'Enter verification code' : 'Enter your phone number',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _showOtp
                    ? 'We sent a 6-digit code to ${auth.phone ?? "your phone"}'
                    : 'We\'ll text you a one-time code to sign in',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              if (!_showOtp) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s()-]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    auth.error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
                const Spacer(),
                QueXPrimaryButton(
                  label: 'Send Code',
                  isLoading: auth.isLoading,
                  onPressed: _sendOtp,
                ),
              ] else ...[
                Center(
                  child: Pinput(
                    length: AppConstants.otpLength,
                    defaultPinTheme: PinTheme(
                      width: 52,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 52,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onCompleted: _verifyOtp,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Demo OTP: ${AppConstants.demoOtp}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
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
                const Spacer(),
                QueXPrimaryButton(
                  label: 'Verify & Continue',
                  isLoading: auth.isLoading,
                  onPressed: () {},
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
