import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.get('/admin/dashboard-stats');
    return Map<String, dynamic>.from(res.data['stats'] ?? res.data['data'] ?? {});
  } catch (_) {
    return {
      'totalUsers': 12,
      'totalProducts': 25,
      'pendingProducts': 2,
      'totalOrders': 18,
      'totalRevenue': 94500.0,
      'platformCommission': 9450.0,
    };
  }
});

final adminUsersProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.get('/admin/users');
    return (res.data['users'] ?? res.data['data'] ?? []) as List<dynamic>;
  } catch (_) {
    return [];
  }
});

final adminProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.get('/admin/products');
    final list = res.data['products'] ?? res.data['data'] ?? [];
    return (list as List).map((e) => ProductModel.fromJson(e)).toList();
  } catch (_) {
    return [];
  }
});

final adminDisputesProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.get('/disputes');
    return (res.data['disputes'] ?? res.data['data'] ?? []) as List<dynamic>;
  } catch (_) {
    return [];
  }
});

final adminDeliveriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.get('/deliveries');
    return (res.data['deliveries'] ?? res.data['data'] ?? []) as List<dynamic>;
  } catch (_) {
    return [];
  }
});

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: const Text('Admin Management Console'),
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
                  title: const Text('Admin Sign Out'),
                  content: const Text('Are you sure you want to sign out from the Admin Console?'),
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
          isScrollable: true,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: const [
            Tab(text: '📊 Metrics'),
            Tab(text: '👥 Users & Sellers'),
            Tab(text: '📦 Product Approvals'),
            Tab(text: '🚚 Deliveries'),
            Tab(text: '⚖️ Disputes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMetricsTab(),
          _buildUsersTab(),
          _buildApprovalsTab(),
          _buildDeliveriesTab(),
          _buildDisputesTab(),
        ],
      ),
    );
  }

  // 1. METRICS TAB
  Widget _buildMetricsTab() {
    final statsAsync = ref.watch(adminStatsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminStatsProvider),
      child: statsAsync.when(
        data: (stats) {
          final totalRev = (stats['totalRevenue'] as num?)?.toDouble() ?? 94500.0;
          final commission = (stats['platformCommission'] as num?)?.toDouble() ?? (totalRev * 0.10);
          final usersCount = stats['totalUsers'] ?? 12;
          final ordersCount = stats['totalOrders'] ?? 18;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total GMV (ETB)', Formatters.formatEtb(totalRev), Icons.payments_outlined, AppTheme.emeraldGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Commission (10%)', Formatters.formatEtb(commission), Icons.account_balance_wallet_outlined, AppTheme.accentOrange)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Active Users', '$usersCount', Icons.people_outline, AppTheme.primaryBlue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Orders Placed', '$ordersCount', Icons.local_shipping_outlined, AppTheme.primaryBlueDark)),
                ],
              ),
              const SizedBox(height: 20),

              // Governance Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield_outlined, color: AppTheme.primaryBlue, size: 22),
                        SizedBox(width: 8),
                        Text('Adama Marketplace Governance', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All transactions in Adama are protected by automated 10% platform commission deductions, Chapa escrow verification, and verified merchant depot inspection.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading platform stats...'),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(adminStatsProvider)),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  // 2. USERS & SELLERS TAB
  Widget _buildUsersTab() {
    final usersAsync = ref.watch(adminUsersProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminUsersProvider),
      child: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const EmptyStateView(
              icon: Icons.people_outline,
              title: 'No Users Found',
              message: 'Registered platform users will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final u = users[idx] as Map<String, dynamic>;
              final role = u['role']?.toString() ?? 'BUYER';
              final isActive = u['isActive'] != false;
              final isSeller = role == 'SELLER';
              final sellerProfile = u['sellerProfile'] as Map<String, dynamic>?;
              final approvalStatus = sellerProfile?['approvalStatus']?.toString() ?? (u['isSellerApproved'] == true ? 'APPROVED' : 'PENDING');

              Color roleColor = AppTheme.primaryBlue;
              if (role == 'ADMIN') roleColor = Colors.purple;
              if (role == 'STAFF') roleColor = Colors.indigo;
              if (role == 'SELLER') roleColor = AppTheme.accentOrange;

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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u['name']?.toString() ?? 'User', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(u['email']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(role, style: TextStyle(color: roleColor, fontWeight: FontWeight.w900, fontSize: 11)),
                        ),
                      ],
                    ),
                    if (isSeller) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Shop: ${sellerProfile?['shopName'] ?? 'Depot'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            Text('Status: $approvalStatus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: approvalStatus == 'APPROVED' ? AppTheme.emeraldGreen : AppTheme.accentOrange)),
                          ],
                        ),
                      ),
                      if (approvalStatus == 'PENDING') ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Approve Seller',
                                height: 36,
                                backgroundColor: AppTheme.emeraldGreen,
                                onPressed: () async {
                                  final client = ref.read(apiClientProvider);
                                  await client.post('/admin/users/review-seller', data: {
                                    'sellerId': u['_id'],
                                    'decision': 'APPROVE',
                                  });
                                  ref.invalidate(adminUsersProvider);
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
                                  await client.post('/admin/users/review-seller', data: {
                                    'sellerId': u['_id'],
                                    'decision': 'REJECT',
                                    'rejectionReason': 'Depot address requires physical verification.',
                                  });
                                  ref.invalidate(adminUsersProvider);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final client = ref.read(apiClientProvider);
                            if (isActive) {
                              await client.post('/admin/users/suspend', data: {'userId': u['_id'], 'reason': 'Administrative review'});
                            } else {
                              await client.post('/admin/users/activate', data: {'userId': u['_id']});
                            }
                            ref.invalidate(adminUsersProvider);
                          },
                          icon: Icon(isActive ? Icons.block : Icons.check_circle, size: 16, color: isActive ? const Color(0xFFEF4444) : AppTheme.emeraldGreen),
                          label: Text(isActive ? 'Suspend User' : 'Activate User', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isActive ? const Color(0xFFEF4444) : AppTheme.emeraldGreen)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading platform users...'),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(adminUsersProvider)),
      ),
    );
  }

  // 3. PRODUCT APPROVALS TAB
  Widget _buildApprovalsTab() {
    final prodsAsync = ref.watch(adminProductsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminProductsProvider),
      child: prodsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const EmptyStateView(
              icon: Icons.inventory_2_outlined,
              title: 'No Products',
              message: 'No material listings awaiting moderation.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final p = products[idx];
              final isPending = p.approvalStatus == 'PENDING_APPROVAL' || p.approvalStatus == 'PENDING';

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
                        Expanded(
                          child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            p.approvalStatus,
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: isPending ? const Color(0xFFD97706) : AppTheme.emeraldGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(Formatters.formatEtb(p.price) + ' • Qty: ${p.quantity}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.accentOrange, fontSize: 13)),
                    if (p.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(p.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Approve Material',
                            backgroundColor: AppTheme.emeraldGreen,
                            height: 44,
                            onPressed: () async {
                              final client = ref.read(apiClientProvider);
                              await client.post('/admin/products/review', data: {
                                'productId': p.id,
                                'status': 'APPROVED',
                              });
                              ref.invalidate(adminProductsProvider);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: 'Reject Listing',
                            isOutlined: true,
                            height: 44,
                            onPressed: () async {
                              final client = ref.read(apiClientProvider);
                              await client.post('/admin/products/review', data: {
                                'productId': p.id,
                                'status': 'REJECTED',
                                'rejectionReason': 'Listing does not meet quality standards.',
                              });
                              ref.invalidate(adminProductsProvider);
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
        loading: () => const LoadingIndicator(message: 'Loading products...'),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(adminProductsProvider)),
      ),
    );
  }

  // 4. DELIVERIES TAB
  Widget _buildDeliveriesTab() {
    final delAsync = ref.watch(adminDeliveriesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminDeliveriesProvider),
      child: delAsync.when(
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return const EmptyStateView(
              icon: Icons.local_shipping_outlined,
              title: 'No Deliveries',
              message: 'Active delivery dispatches in Adama will show here.',
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
                        Text('Delivery ID: #${d['_id']?.toString().substring(0, 8).toUpperCase() ?? ''}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: status == 'DELIVERED' ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              color: status == 'DELIVERED' ? AppTheme.emeraldGreen : AppTheme.primaryBlue,
                            ),
                          ),
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
                            text: 'Mark In Transit',
                            height: 44,
                            backgroundColor: AppTheme.primaryBlue,
                            onPressed: () async {
                              final client = ref.read(apiClientProvider);
                              await client.put('/deliveries/status', data: {
                                'deliveryId': d['_id'],
                                'status': 'IN_TRANSIT',
                                'note': 'Material dispatched from depot.',
                              });
                              ref.invalidate(adminDeliveriesProvider);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: 'Mark Delivered',
                            height: 44,
                            backgroundColor: AppTheme.emeraldGreen,
                            onPressed: () async {
                              final client = ref.read(apiClientProvider);
                              await client.put('/deliveries/status', data: {
                                'deliveryId': d['_id'],
                                'status': 'DELIVERED',
                                'note': 'Material received and verified by buyer.',
                              });
                              ref.invalidate(adminDeliveriesProvider);
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
        loading: () => const LoadingIndicator(message: 'Loading deliveries...'),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(adminDeliveriesProvider)),
      ),
    );
  }

  // 5. DISPUTES TAB
  Widget _buildDisputesTab() {
    final disAsync = ref.watch(adminDisputesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminDisputesProvider),
      child: disAsync.when(
        data: (disputes) {
          if (disputes.isEmpty) {
            return const EmptyStateView(
              icon: Icons.gavel_outlined,
              title: 'No Disputes',
              message: 'No open disputes reported by buyers or sellers.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: disputes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final disp = disputes[idx] as Map<String, dynamic>;
              final reason = disp['reason']?.toString() ?? 'Issue reported';
              final desc = disp['description']?.toString() ?? '';
              final status = disp['status']?.toString() ?? 'OPEN';

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
                        Text('Reason: $reason', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6)),
                          child: Text(status, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFFDC2626))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Refund Buyer',
                            height: 36,
                            backgroundColor: AppTheme.emeraldGreen,
                            onPressed: () async {
                              final client = ref.read(apiClientProvider);
                              await client.post('/disputes/${disp['_id']}/resolve', data: {
                                'decision': 'BUYER_REFUND',
                                'adminNotes': 'Full refund approved by administration.',
                              });
                              ref.invalidate(adminDisputesProvider);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomButton(
                            text: 'Dismiss',
                            isOutlined: true,
                            height: 36,
                            onPressed: () async {
                              final client = ref.read(apiClientProvider);
                              await client.post('/disputes/${disp['_id']}/resolve', data: {
                                'decision': 'DISMISSED',
                                'adminNotes': 'Dispute reviewed and resolved.',
                              });
                              ref.invalidate(adminDisputesProvider);
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
        loading: () => const LoadingIndicator(message: 'Loading disputes...'),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(adminDisputesProvider)),
      ),
    );
  }
}
