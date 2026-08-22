import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 44,
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.check_circle, size: 54, color: AppTheme.emeraldGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase()} has been placed and is being prepared for dispatch.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const Spacer(),
              CustomButton(
                text: 'Track Order Status',
                icon: Icons.local_shipping_outlined,
                onPressed: () => context.go('/orders'),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Back to Home',
                isOutlined: true,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
