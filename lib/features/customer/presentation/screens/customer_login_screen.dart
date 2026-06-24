import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class CustomerLoginScreen extends ConsumerStatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  ConsumerState<CustomerLoginScreen> createState() =>
      _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends ConsumerState<CustomerLoginScreen> {
  final _phoneController = TextEditingController(text: '+1 ');
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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      appBar: const QueXAppBar(title: 'Sign In', showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const QueXLogo(size: 48),
              const SizedBox(height: 24),
              Text(
                _showOtp ? 'Enter verification code' : 'Enter your phone number',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
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
                  Text(auth.error!, style: const TextStyle(color: AppColors.error)),
                ],
                const Spacer(),
                PrimaryButton(
                  label: 'Send Code',
                  isLoading: auth.isLoading,
                  onPressed: _sendOtp,
                ),
              ] else ...[
                Center(
                  child: Pinput(
                    length: AppConstants.otpLength,
                    defaultPinTheme: PinTheme(
                      width: 48,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 48,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(12),
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
                PrimaryButton(
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
