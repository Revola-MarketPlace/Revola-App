import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../controllers/orders_controller.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final order = orders.firstWhere((o) => o.id == orderId, orElse: () => orders.first);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          Text(order.orderStatus, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Placed on ${Formatters.formatDate(order.createdAt)}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      const Divider(height: 24),
                      Text('Delivery Address: ${order.deliveryAddress ?? 'Adama City'}', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Order Items
                const Text('Items in Order', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                const SizedBox(height: 10),
                ...order.items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.product.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(Formatters.formatEtb(item.price * item.quantity), style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.accentOrange)),
                    ],
                  ),
                )),
                const SizedBox(height: 16),

                // Actions
                CustomButton(
                  text: 'Live Delivery Tracking',
                  icon: Icons.map_outlined,
                  onPressed: () => context.push('/tracking/${order.id}'),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Report Dispute / Issue',
                  isOutlined: true,
                  onPressed: () => context.push('/dispute-form/${order.id}'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
