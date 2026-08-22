import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../catalog/presentation/controllers/catalog_controller.dart';

final singleProductProvider = FutureProvider.family<ProductModel, String>((ref, id) async {
  return ref.watch(productRepositoryProvider).getProductById(id);
});

class MaterialDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const MaterialDetailsScreen({super.key, required this.productId});

  @override
  ConsumerState<MaterialDetailsScreen> createState() => _MaterialDetailsScreenState();
}

class _MaterialDetailsScreenState extends ConsumerState<MaterialDetailsScreen> {
  int _activeImageIndex = 0;
  int _orderQty = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(singleProductProvider(widget.productId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Material Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing material link...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          final images = product.images.isNotEmpty ? product.images : [product.primaryImage];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Gallery
                      AspectRatio(
                        aspectRatio: 1.1,
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: images[_activeImageIndex],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Text(
                                  product.condition.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.textPrimary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Thumbnails
                      if (images.length > 1)
                        Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, idx) => GestureDetector(
                              onTap: () => setState(() => _activeImageIndex = idx),
                              child: Container(
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _activeImageIndex == idx ? AppTheme.primaryBlue : AppTheme.borderColor,
                                    width: 2,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: CachedNetworkImage(imageUrl: images[idx], fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),

                      // Material Header
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Formatters.formatEtb(product.price),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.accentOrange,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: product.inStock ? const Color(0xFFF0FDF4) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    product.inStock ? '${product.quantity} in stock' : 'Out of Stock',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: product.inStock ? AppTheme.emeraldGreen : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${product.location?.subCity ?? 'Adama'}, ${product.location?.city ?? 'Adama'}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(color: AppTheme.borderColor),
                            const SizedBox(height: 12),

                            // Description
                            const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                            ),
                            const SizedBox(height: 20),
                            const Divider(color: AppTheme.borderColor),
                            const SizedBox(height: 12),

                            // Seller Info Card
                            const Text('Verified Seller', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                    child: const Icon(Icons.storefront, color: AppTheme.primaryBlue),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.seller?.shopName ?? product.seller?.name ?? 'Seller Shop',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                                        ),
                                        Text(
                                          product.seller?.shopAddress ?? 'Adama City',
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppTheme.borderColor)),
                ),
                child: Row(
                  children: [
                    // Quantity Counter
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: _orderQty > 1 ? () => setState(() => _orderQty--) : null,
                          ),
                          Text('$_orderQty', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: _orderQty < product.quantity ? () => setState(() => _orderQty++) : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Add to Cart',
                        icon: Icons.add_shopping_cart,
                        onPressed: product.inStock
                            ? () async {
                                final auth = ref.read(authControllerProvider);
                                if (!auth.isAuthenticated || auth.user?.role != 'BUYER') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Please sign in with a Buyer account to add materials to cart.'),
                                      action: SnackBarAction(label: 'Sign In', textColor: AppTheme.accentOrange, onPressed: () => context.push('/login')),
                                    ),
                                  );
                                  return;
                                }
                                final ok = await ref.read(cartControllerProvider.notifier).addToCart(
                                  product.id,
                                  quantity: _orderQty,
                                );
                                if (ok && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to Cart!'),
                                      backgroundColor: AppTheme.emeraldGreen,
                                    ),
                                  );
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading material details...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(singleProductProvider(widget.productId)),
        ),
      ),
    );
  }
}
