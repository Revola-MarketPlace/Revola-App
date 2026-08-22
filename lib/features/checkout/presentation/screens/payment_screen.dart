import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/providers/core_providers.dart';
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
  bool _isLoading = true;
  String? _errorMessage;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  @override
  void dispose() {
    _receiptCtrl.dispose();
    super.dispose();
  }

  Future<void> _initializePayment() async {
    if (widget.method != 'CHAPA') {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final client = ref.read(apiClientProvider);
      final res = await client.post('/payments/initialize', data: {
        'orderId': widget.orderId,
        'paymentMethod': 'CHAPA',
      });

      final url = res.data['paymentUrl'] ?? res.data['checkoutUrl'] ?? res.data['data']?['checkout_url'];
      if (url != null && url.toString().isNotEmpty) {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                if (url.contains('success') || url.contains('callback') || url.contains('tx_ref')) {
                  _verifyChapaPayment();
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(url.toString()));

        setState(() {
          _webViewController = controller;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load Chapa checkout gateway.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _verifyChapaPayment() async {
    try {
      final client = ref.read(apiClientProvider);
      await client.get('/payments/verify/ORD-${widget.orderId}');
      if (mounted) {
        context.go('/order-success/${widget.orderId}');
      }
    } catch (_) {
      if (mounted) {
        context.go('/order-success/${widget.orderId}');
      }
    }
  }

  Future<void> _submitManualReceipt() async {
    if (_receiptCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter transaction reference')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/payments/submit-receipt', data: {
        'orderId': widget.orderId,
        'paymentMethod': widget.method,
        'transactionReference': _receiptCtrl.text.trim(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/order-success/${widget.orderId}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFEF4444)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.method == 'CHAPA' && _webViewController != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chapa Secure Checkout'),
          actions: [
            TextButton(
              onPressed: _verifyChapaPayment,
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
            ),
          ],
        ),
        body: WebViewWidget(controller: _webViewController!),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
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
                    const Text('Commercial Bank of Ethiopia (CBE) Instructions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Transfer order total to CBE Account: 1000234567890 (Revola Materials)\n2. Enter the transaction TT reference code below for verification.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'CBE Reference / TT Number',
                      hintText: 'e.g. FT2608123456',
                      controller: _receiptCtrl,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(text: 'Submit Reference for Verification', isLoading: _isLoading, onPressed: _submitManualReceipt),
                  ] else if (widget.method == 'TELEBIRR') ...[
                    const Text('Telebirr Payment Instructions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Open Telebirr SuperApp and transfer to Merchant ID: 887766\n2. Enter the Telebirr transaction code below.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Telebirr Transaction Code',
                      hintText: 'e.g. TX-TELEBIRR-987654',
                      controller: _receiptCtrl,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(text: 'Submit Telebirr Reference', isLoading: _isLoading, onPressed: _submitManualReceipt),
                  ] else ...[
                    if (_errorMessage != null)
                      Text(_errorMessage!, style: const TextStyle(color: Color(0xFFEF4444))),
                    const SizedBox(height: 16),
                    CustomButton(text: 'Proceed to Payment Gateway', onPressed: _initializePayment),
                  ],
                ],
              ),
            ),
    );
  }
}
