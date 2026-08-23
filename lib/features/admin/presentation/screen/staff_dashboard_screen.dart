import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';

final staffDeliveriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.get('/deliveries');
    return (res.data['deliveries'] ?? res.data['data'] ?? []) as List<dynamic>;
  } catch (_) {
    return [];
  }
});

final staffPendingPaymentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.get('/payments/pending');
    return (res.data['payments'] ?? res.data['data'] ?? []) as List<dynamic>;
  } catch (_) {
    return [];
  }
});

final staffOrdersProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.get('/orders');
    return (res.data['orders'] ?? res.data['data'] ?? []) as List<dynamic>;
  } catch (_) {
    return [];
  }
});

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Staff Operations Hub'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 24),
            tooltip: 'Sign Out',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Staff Sign Out'),
                  content: const Text('Are you sure you want to sign out from the Staff Hub?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: const [
            Tab(text: '🚚 Deliveries Queue'),
            Tab(text: '💳 Verification Queue'),
            Tab(text: '📦 All Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeliveriesTab(),
          _buildPaymentsTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  // 1. DELIVERIES QUEUE
  Widget _buildDeliveriesTab() {
    final delAsync = ref.watch(staffDeliveriesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(staffDeliveriesProvider),
      child: delAsync.when(
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return const EmptyStateView(
              icon: Icons.local_shipping_outlined,
              title: 'Queue Clear',
              message: 'No pending delivery dispatches in Adama.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: deliveries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final d = deliveries[idx] as Map<String, dynamic>;
              final status = d['status']?.toString() ?? 'PENDING';
              final fee = (d['fee'] as num?)?.toDouble() ?? 150.0;
              final id = d['_id']?.toString() ?? '';

              return Container(
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
                        Text('Dispatch #${id.substring(0, id.length > 8 ? 8 : id.length).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                          child: Text(status.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: AppTheme.primaryBlue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Delivery Fee: ${Formatters.formatEtb(fee)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textPrimary)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'In Transit',
                            height: 36,
                            backgroundColor: AppTheme.accentOrange,
                            onPressed: () async {
                              final client = ref.read(apiClientProvider);
                              await client.put('/deliveries/status', data: {
                                'deliveryId': id,
                                'status': 'IN_TRANSIT',
                                'note': 'Driver Bekele dispatched material to destination.',
                              });
                              ref.invalidate(staffDeliveriesProvider);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomButton(
                            text: 'Delivered',
                            height: 36,
                            backgroundColor: AppTheme.emeraldGreen,
                            onPressed: () async {
                              final client = ref.read(apiClientProvider);
                              await client.put('/deliveries/status', data: {
                                'deliveryId': id,
                                'status': 'DELIVERED',
                                'note': 'Material received and verified at site.',
                              });
                              ref.invalidate(staffDeliveriesProvider);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading delivery queue...'),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(staffDeliveriesProvider)),
      ),
    );
  }

  // 2. PAYMENT VERIFICATION QUEUE
  Widget _buildPaymentsTab() {
    final payAsync = ref.watch(staffPendingPaymentsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(staffPendingPaymentsProvider),
      child: payAsync.when(
        data: (payments) {
          if (payments.isEmpty) {
            return const EmptyStateView(
              icon: Icons.check_circle_outline,
              title: 'Verification Queue Clear',
              message: 'No manual bank transfer payments awaiting staff confirmation.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final p = payments[idx] as Map<String, dynamic>;
              final amount = (p['amount'] as num?)?.toDouble() ?? 0.0;
              final refNumber = p['transactionReference']?.toString() ?? p['transactionId']?.toString() ?? 'N/A';

              return Container(
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
                        Text('Ref: $refNumber', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        Text(Formatters.formatEtb(amount), style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accentOrange, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Method: ${p['paymentMethod'] ?? 'BANK_TRANSFER'}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Approve & Confirm',
                            backgroundColor: AppTheme.emeraldGreen,
                            height: 36,
                            onPressed: () async {
                              final client = ref.read(apiClientProvider);
                              await client.post('/payments/verify-manual', data: {
                                'paymentId': p['_id'],
                                'status': 'PAID',
                              });
                              ref.invalidate(staffPendingPaymentsProvider);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomButton(
                            text: 'Reject',
                            isOutlined: true,
                            height: 36,
                            onPressed: () async {
                              final client = ref.read(apiClientProvider);
                              await client.post('/payments/verify-manual', data: {
                                'paymentId': p['_id'],
                                'status': 'FAILED',
                                'notes': 'Receipt or reference could not be verified on bank records.',
                              });
                              ref.invalidate(staffPendingPaymentsProvider);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading pending verifications...'),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(staffPendingPaymentsProvider)),
      ),
    );
  }

  // 3. ALL ORDERS TAB
  Widget _buildOrdersTab() {
    final ordAsync = ref.watch(staffOrdersProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(staffOrdersProvider),
      child: ordAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'No Orders',
              message: 'Placed customer orders will show here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final o = orders[idx] as Map<String, dynamic>;
              final orderNum = o['orderNumber']?.toString() ?? o['trackingNumber']?.toString() ?? o['_id']?.toString().substring(0, 8) ?? '';
              final status = o['orderStatus']?.toString() ?? 'PENDING';
              final total = (o['total'] as num?)?.toDouble() ?? 0.0;
              final items = (o['items'] as List<dynamic>?) ?? [];

              return Container(
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
                        Text('Order #$orderNum', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                          child: Text(status.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: AppTheme.primaryBlue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${items.length} items • ${Formatters.formatEtb(total)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.accentOrange, fontSize: 13)),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading orders...'),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(staffOrdersProvider)),
      ),
    );
  }
}
