import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String method;
  // paymentUrl is passed directly from checkout response — no extra API call needed
  final String? paymentUrl;
  final String? transactionId;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.method,
    this.paymentUrl,
    this.transactionId,
  });

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
    _loadPaymentUrl();
  }

  void _loadPaymentUrl() {
    final url = widget.paymentUrl;

    if (url != null && url.isNotEmpty) {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              // Detect Chapa return/callback URL and verify payment
              final uri = request.url;
              if (uri.contains('payment/callback') ||
                  uri.contains('tx_ref=') ||
                  uri.contains('success') ||
                  uri.contains('revola://')) {
                _verifyChapaPayment();
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(url));

      setState(() {
        _webViewController = controller;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No Chapa checkout URL was returned from the server.\n\nPlease go back and try again.';
      });
    }
  }

  Future<void> _verifyChapaPayment() async {
    if (!mounted) return;
    // Navigate to order success screen — backend webhook will handle actual verification
    context.go('/order-success/${widget.orderId}');
  }

  @override
  Widget build(BuildContext context) {
    if (_webViewController != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chapa Secure Checkout'),
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textPrimary,
          elevation: 1,
          actions: [
            TextButton(
              onPressed: _verifyChapaPayment,
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
            ),
          ],
        ),
        body: WebViewWidget(controller: _webViewController!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chapa Payment'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 1,
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryBlue),
                  SizedBox(height: 16),
                  Text(
                    'Loading Chapa Checkout...',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 56),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? 'Payment failed to load.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    CustomButton(
                      text: 'Go Back to Cart',
                      onPressed: () => context.go('/cart'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
