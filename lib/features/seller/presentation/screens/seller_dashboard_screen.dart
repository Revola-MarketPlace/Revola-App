import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../controllers/seller_controller.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(sellerProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metrics Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Active Listings', style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        productsAsync.when(
                          data: (prods) => Text('${prods.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                          loading: () => const Text('...'),
                          error: (_, __) => const Text('0'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Earnings (ETB)', style: TextStyle(fontSize: 12, color: AppTheme.accentOrange, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('48,500.00', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            CustomButton(
              text: 'Add New Material Listing',
              icon: Icons.add,
              onPressed: () => context.push('/seller-add-material'),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'View My Materials Inventory',
              isOutlined: true,
              icon: Icons.inventory_2_outlined,
              onPressed: () => context.push('/seller-materials'),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'View Seller Orders',
              isOutlined: true,
              icon: Icons.receipt_long_outlined,
              onPressed: () => context.push('/seller-orders'),
            ),
          ],
        ),
      ),
    );
  }
}
