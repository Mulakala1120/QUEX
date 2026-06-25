import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/theme/customer_auth_theme.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/core/widgets/quex_brand_logo.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class CustomerLoginScreen extends ConsumerStatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  ConsumerState<CustomerLoginScreen> createState() =>
      _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends ConsumerState<CustomerLoginScreen> {
  final _phoneController = TextEditingController(text: '+91 ');
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    await ref.read(authStateProvider.notifier).sendOtp(_phoneController.text);
  }

  Future<void> _verifyOtp(String otp) async {
    final success = await ref.read(authStateProvider.notifier).verifyOtp(otp);
    if (success && mounted) context.go('/customer/categories');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final showOtp = auth.otpSent;

    return Theme(
      data: CustomerAuthTheme.light,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: CustomerAuthColors.background,
          foregroundColor: CustomerAuthColors.textPrimary,
          elevation: 0,
        ),
        backgroundColor: CustomerAuthColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const QueXBrandLogo(size: 48, style: QueXLogoStyle.light),
                const SizedBox(height: 24),
                Text(
                  showOtp ? 'Enter verification code' : 'Enter your phone number',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  showOtp
                      ? 'We sent a 6-digit code to ${auth.phone ?? "your phone"}'
                      : 'We\'ll text you a one-time code to sign in',
                  style: const TextStyle(color: CustomerAuthColors.textSecondary),
                ),
                const SizedBox(height: 32),
                if (!showOtp) ...[
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s()-]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: '+91 98765 43210',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      auth.error!,
                      style: const TextStyle(color: CustomerAuthColors.primaryDark),
                    ),
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
                      controller: _otpController,
                      length: AppConstants.otpLength,
                      autofocus: true,
                      defaultPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(color: CustomerAuthColors.divider),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: CustomerAuthColors.primary, width: 2),
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
                        color: CustomerAuthColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        auth.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                  const Spacer(),
                  PrimaryButton(
                    label: 'Verify & Continue',
                    isLoading: auth.isLoading,
                    onPressed: () => _verifyOtp(_otpController.text),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: auth.isLoading
                          ? null
                          : () {
                              ref
                                  .read(authStateProvider.notifier)
                                  .resetLoginFlow();
                              _otpController.clear();
                            },
                      child: const Text('Change phone number'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
