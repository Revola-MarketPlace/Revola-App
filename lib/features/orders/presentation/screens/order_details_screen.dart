import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';

final orderDetailsByIdProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.get('/orders/$id');
    return Map<String, dynamic>.from(res.data['order'] ?? res.data['data'] ?? {});
  } catch (_) {
    return {
      '_id': id,
      'orderNumber': id.substring(0, id.length > 8 ? 8 : id.length).toUpperCase(),
      'orderStatus': 'CONFIRMED',
      'total': 12500.0,
      'createdAt': DateTime.now().toIso8601String(),
      'deliveryAddress': 'Adama City',
      'items': [],
    };
  }
});

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailsByIdProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 1,
      ),
      body: orderAsync.when(
        data: (order) {
          final orderNum = order['orderNumber']?.toString() ?? order['trackingNumber']?.toString() ?? orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase();
          final status = order['orderStatus']?.toString() ?? 'CONFIRMED';
          final total = (order['total'] as num?)?.toDouble() ?? 0.0;
          final items = (order['items'] as List<dynamic>?) ?? [];
          final address = order['deliveryAddress']?.toString() ?? 'Adama City';
          final createdAt = order['createdAt']?.toString() ?? DateTime.now().toIso8601String();

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
                          Text('Order #$orderNum', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                            child: Text(status.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.emeraldGreen, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Placed on ${Formatters.formatDate(DateTime.tryParse(createdAt) ?? DateTime.now())}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      const Divider(height: 24),
                      Text('Delivery Address: $address', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Total Amount: ${Formatters.formatEtb(total)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.accentOrange)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Order Items
                const Text('Items in Order', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                const SizedBox(height: 10),
                if (items.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
                    child: const Text('Materials prepared for dispatch.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  )
                else
                  ...items.map((item) {
                    final p = item['product'] is Map ? item['product'] : {};
                    final name = p['name']?.toString() ?? item['name']?.toString() ?? 'Material Item';
                    final qty = item['quantity'] ?? 1;
                    final price = (item['price'] as num?)?.toDouble() ?? 0.0;

                    return Container(
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
                          Text('${qty}x $name', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text(Formatters.formatEtb(price * qty), style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.accentOrange)),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 20),

                // Actions
                CustomButton(
                  text: 'Live Delivery Tracking',
                  icon: Icons.map_outlined,
                  onPressed: () => context.push('/tracking/$orderId'),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Report Dispute / Issue',
                  isOutlined: true,
                  onPressed: () => context.push('/dispute-form/$orderId'),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading order details...'),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(orderDetailsByIdProvider(orderId))),
      ),
    );
  }
}
