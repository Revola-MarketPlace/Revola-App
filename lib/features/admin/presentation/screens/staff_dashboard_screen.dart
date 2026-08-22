import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';

final pendingPaymentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.get('/payments/pending');
    return res.data['payments'] ?? res.data['data'] ?? [];
  } catch (_) {
    return [];
  }
});

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(pendingPaymentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Verification & Ops'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(pendingPaymentsProvider),
        child: paymentsAsync.when(
          data: (payments) {
            if (payments.isEmpty) {
              return const EmptyStateView(
                icon: Icons.check_circle_outline,
                title: 'Queue Clear',
                message: 'No pending bank receipts awaiting verification.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final p = payments[idx];
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
                          Text('Ref: ${p['transactionReference'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          Text(Formatters.formatEtb(p['amount']), style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accentOrange)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Method: ${p['paymentMethod'] ?? 'BANK_TRANSFER'}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Verify & Confirm',
                              backgroundColor: AppTheme.emeraldGreen,
                              height: 38,
                              onPressed: () async {
                                final client = ref.read(apiClientProvider);
                                await client.post('/payments/verify-manual', data: {
                                  'paymentId': p['_id'],
                                  'status': 'PAID',
                                });
                                ref.invalidate(pendingPaymentsProvider);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomButton(
                              text: 'Reject',
                              isOutlined: true,
                              height: 38,
                              onPressed: () async {
                                final client = ref.read(apiClientProvider);
                                await client.post('/payments/verify-manual', data: {
                                  'paymentId': p['_id'],
                                  'status': 'FAILED',
                                  'notes': 'Invalid bank transfer reference',
                                });
                                ref.invalidate(pendingPaymentsProvider);
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
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorView(message: e.toString()),
        ),
      ),
    );
  }
}
