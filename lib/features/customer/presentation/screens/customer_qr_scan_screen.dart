import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/utils/geo_utils.dart';

/// Scan a QueX queue QR to jump straight to check-in.
class CustomerQrScanScreen extends ConsumerStatefulWidget {
  const CustomerQrScanScreen({super.key});

  @override
  ConsumerState<CustomerQrScanScreen> createState() =>
      _CustomerQrScanScreenState();
}

class _CustomerQrScanScreenState extends ConsumerState<CustomerQrScanScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    final businessId = parseQuexBusinessId(code);
    if (businessId == null) return;

    _handled = true;
    context.pushReplacement('/customer/check-in/$businessId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Queue QR'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
                Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.accent, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Point at the QR code at the salon or clinic front desk',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    // Demo: simulate scan of featured salon
                    context.pushReplacement('/customer/check-in/biz_1');
                  },
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Demo: Join Looks Salon'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
