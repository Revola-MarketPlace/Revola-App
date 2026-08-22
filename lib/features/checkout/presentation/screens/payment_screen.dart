import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String method;

  const PaymentScreen({super.key, required this.orderId, required this.method});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _receiptCtrl = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _receiptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Placed Successfully!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primaryBlueDark)),
                  const SizedBox(height: 4),
                  Text('Order ID: ${widget.orderId}', style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (widget.method == 'BANK_TRANSFER') ...[
              const Text('CBE / Awash Bank Instructions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                '1. Transfer order total to Commercial Bank of Ethiopia: 1000234567890 (Revola Materials)\n2. Enter the transaction reference code below for verification.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Bank Reference / TT Number',
                hintText: 'e.g. FT2608123456',
                controller: _receiptCtrl,
              ),
            ] else if (widget.method == 'TELEBIRR') ...[
              const Text('Telebirr Payment Instructions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                '1. Open Telebirr SuperApp and transfer to Merchant ID: 887766\n2. Submit receipt or transaction reference below.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Telebirr Transaction ID',
                hintText: 'e.g. TX-TELEBIRR-987654',
                controller: _receiptCtrl,
              ),
            ] else ...[
              const Text('Chapa Secure Checkout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                'You will be redirected to complete your card or mobile payment securely.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
              ),
            ],

            const SizedBox(height: 32),
            CustomButton(
              text: 'Confirm & Verify Payment',
              isLoading: _isProcessing,
              onPressed: () {
                setState(() => _isProcessing = true);
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() => _isProcessing = false);
                    context.go('/order-success/${widget.orderId}');
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
