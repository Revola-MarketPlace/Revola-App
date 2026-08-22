import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/geofence_helper.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../orders/presentation/controllers/orders_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressCtrl = TextEditingController(text: 'Bole Subcity, Kebele 02, Adama');
  final _phoneCtrl = TextEditingController(text: '+251911223344');
  final _notesCtrl = TextEditingController();

  double _lat = AppConstants.adamaCenterLat;
  double _lng = AppConstants.adamaCenterLng;
  String _paymentMethod = 'CHAPA'; // 'CHAPA', 'TELEBIRR', 'BANK_TRANSFER'

  double _deliveryFee = 250.0;
  bool _isLoadingFee = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _calculateFee();
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _calculateFee() async {
    setState(() => _isLoadingFee = true);
    try {
      final cart = ref.read(cartControllerProvider).cart;
      if (cart != null && cart.items.isNotEmpty) {
        final res = await ref.read(orderRepositoryProvider).estimateDeliveryFee(
          latitude: _lat,
          longitude: _lng,
          productIds: cart.items.map((e) => e.product.id).toList(),
        );
        setState(() {
          _deliveryFee = (res['deliveryFee'] as num?)?.toDouble() ?? 250.0;
          _isLoadingFee = false;
        });
      }
    } catch (_) {
      setState(() {
        _deliveryFee = 250.0;
        _isLoadingFee = false;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (!GeofenceHelper.isInsideAdamaServiceArea(_lat, _lng)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery address is outside Adama service area.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final res = await ref.read(orderRepositoryProvider).checkout(
        paymentMethod: _paymentMethod,
        street: _addressCtrl.text.trim(),
        latitude: _lat,
        longitude: _lng,
        contactPhone: _phoneCtrl.text.trim(),
        deliveryNotes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      );

      ref.read(cartControllerProvider.notifier).fetchCart();

      if (mounted) {
        setState(() => _isSubmitting = false);
        final order = res['order'] as OrderModel;
        context.go('/payment/${order.id}?method=$_paymentMethod');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFEF4444)),
        );
      }
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
              label: 'Street Address & Kebele',
              hintText: 'e.g. Near Stadium, Kebele 04, Adama',
              controller: _addressCtrl,
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

            // 2. Payment Method Selector
            const Text('Select Payment Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),

            _buildPaymentRadio('CHAPA', 'Chapa Gateway (Cards, Mobile Money)', Icons.credit_card_outlined),
            _buildPaymentRadio('TELEBIRR', 'Telebirr SuperApp', Icons.phone_android_outlined),
            _buildPaymentRadio('BANK_TRANSFER', 'CBE / Awash Bank Transfer', Icons.account_balance_outlined),

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
              text: 'Place Order & Pay',
              isLoading: _isSubmitting,
              onPressed: _placeOrder,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRadio(String value, String title, IconData icon) {
    final selected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBlue.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primaryBlue : AppTheme.borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppTheme.primaryBlue : AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                  color: selected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _paymentMethod,
              activeColor: AppTheme.primaryBlue,
              onChanged: (val) => setState(() => _paymentMethod = val!),
            ),
          ],
        ),
      ),
    );
  }
}
