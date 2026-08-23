import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../orders/data/order_repository.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressCtrl = TextEditingController(text: 'Kebele 04, Near Stadium, Adama');
  final _phoneCtrl = TextEditingController(text: '+251911223344');
  String _subCity = 'Bole';
  final double _lat = 8.5400;
  final double _lng = 39.2700;

  double _deliveryFee = 150.0;
  bool _isLoadingFee = false;
  bool _isSubmitting = false;

  final List<String> _subCities = [
    'Bole',
    'Aba Geda',
    'Goro',
    'Boku',
    'Kebele 02',
    'Kebele 03',
    'Kebele 04',
    'Industry Zone',
    'Wonji Road',
  ];

  @override
  void initState() {
    super.initState();
    _estimateFee();
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _estimateFee() async {
    setState(() => _isLoadingFee = true);
    try {
      final cart = ref.read(cartControllerProvider);
      final totalQty = cart.items.fold(0, (sum, item) => sum + item.quantity);
      final fee = await ref.read(orderRepositoryProvider).estimateDeliveryFee(
        latitude: _lat,
        longitude: _lng,
        totalQuantity: totalQty,
      );
      if (mounted) setState(() => _deliveryFee = fee);
    } catch (_) {
      if (mounted) setState(() => _deliveryFee = 150.0);
    } finally {
      if (mounted) setState(() => _isLoadingFee = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_addressCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in your delivery address and contact phone number.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await ref.read(orderRepositoryProvider).checkout(
        deliveryAddress: {
          'streetAddress': _addressCtrl.text.trim(),
          'subCity': _subCity,
          'city': 'Adama',
          'phoneNumber': _phoneCtrl.text.trim(),
          'latitude': _lat,
          'longitude': _lng,
        },
        paymentMethod: 'CHAPA', // Strictly Chapa Test Mode
      );

      final order = result['order'];
      final orderId = order?['_id'] ?? order?['id'] ?? '';
      final paymentUrl = result['paymentUrl'];

      ref.read(cartControllerProvider.notifier).clearCart();

      if (mounted) {
        if (paymentUrl != null && paymentUrl.toString().isNotEmpty) {
          final transactionId = result['transactionId']?.toString() ?? '';
          context.push(
            '/payment/$orderId?method=CHAPA',
            extra: {
              'paymentUrl': paymentUrl.toString(),
              'transactionId': transactionId,
            },
          );
        } else {
          context.go('/order-success/$orderId');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final subtotal = cartState.subtotal;
    final total = subtotal + _deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Delivery Details Section
            const Text('Delivery Location (Adama City)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            CustomTextField(
              label: 'Street Address & Neighborhood',
              hintText: 'e.g. Near Stadium, Kebele 04, Adama',
              controller: _addressCtrl,
            ),
            const SizedBox(height: 12),
            const Text('Subcity / Zone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _subCity,
              items: _subCities.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => _subCity = v ?? 'Bole'),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Contact Phone Number',
              hintText: '+2519...',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            const Divider(color: AppTheme.borderColor),
            const SizedBox(height: 12),

            // 2. Payment Method Selector — Strictly Chapa Test Mode
            const Text('Payment Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryBlue, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.credit_card, color: AppTheme.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chapa Payment Gateway (Test Mode)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.textPrimary)),
                        SizedBox(height: 2),
                        Text('Instant sandbox checkout for Telebirr, CBE, Cards', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 20),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: AppTheme.borderColor),
            const SizedBox(height: 12),

            // 3. Cost Breakdown
            const Text('Order Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Items Subtotal', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      Text(Formatters.formatEtb(subtotal), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Adama Delivery Fee', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      _isLoadingFee
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(Formatters.formatEtb(_deliveryFee), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  const Divider(height: 20, color: AppTheme.borderColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                      Text(
                        Formatters.formatEtb(total),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.accentOrange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Pay with Chapa (Test Mode)',
              isLoading: _isSubmitting,
              onPressed: _placeOrder,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
