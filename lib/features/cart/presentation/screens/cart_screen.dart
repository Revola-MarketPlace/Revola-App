import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    final items = cartState.cart?.items ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: cartState.isLoading
          ? const LoadingIndicator(message: 'Updating cart...')
          : items.isEmpty
              ? EmptyStateView(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Your Cart is Empty',
                  message: 'Explore the marketplace to find reclaimed wood, metals, and electronics.',
                  actionText: 'Browse Materials',
                  onAction: () => context.go('/catalog'),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final item = items[idx];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.borderColor),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: CachedNetworkImage(
                                    imageUrl: item.product.primaryImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Formatters.formatEtb(item.product.price),
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.accentOrange),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity modifier
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      onPressed: item.quantity > 1
                                          ? () => ref.read(cartControllerProvider.notifier).updateQuantity(item.id, item.quantity - 1)
                                          : () => ref.read(cartControllerProvider.notifier).removeItem(item.id),
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      onPressed: () => ref.read(cartControllerProvider.notifier).updateQuantity(item.id, item.quantity + 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Checkout Bottom Summary Bar
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: AppTheme.borderColor)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
                              Text(
                                Formatters.formatEtb(cartState.subtotal),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Proceed to Checkout',
                            icon: Icons.lock_outline,
                            onPressed: () => context.push('/checkout'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
