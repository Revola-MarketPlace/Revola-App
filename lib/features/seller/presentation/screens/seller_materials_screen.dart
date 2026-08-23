import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../controllers/seller_controller.dart';

class SellerMaterialsScreen extends ConsumerWidget {
  const SellerMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(sellerProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Material Listings')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => context.push('/seller-add-material'),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return EmptyStateView(
              icon: Icons.inventory_2_outlined,
              title: 'No Material Listings',
              message: 'List your surplus timber, scrap iron, or plastic containers for buyers in Adama.',
              actionText: 'Create First Listing',
              onAction: () => context.push('/seller-add-material'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final product = products[idx];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          Text(Formatters.formatEtb(product.price), style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accentOrange)),
                        ],
                      ),
                    ),
                    Text(product.approvalStatus, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorView(message: err.toString()),
      ),
    );
  }
}
