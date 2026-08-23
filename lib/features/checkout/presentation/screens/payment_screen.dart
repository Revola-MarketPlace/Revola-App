import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String method;

  const PaymentScreen({super.key, required this.orderId, required this.method});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
      await client.get('/payments/verify-online', queryParameters: {
        'transactionId': 'ORD-' + widget.orderId,
        'provider': 'chapa',
      });
      if (mounted) {
        context.go('/order-success/' + widget.orderId);
      }
    } catch (_) {
      if (mounted) {
        context.go('/order-success/' + widget.orderId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_webViewController != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chapa Test Checkout'),
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
      appBar: AppBar(title: const Text('Chapa Payment')),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryBlue),
                  SizedBox(height: 16),
                  Text('Connecting to Chapa Sandbox Gateway...', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? 'Payment initialization failed',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Retry Chapa Payment',
                      onPressed: _initializePayment,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
