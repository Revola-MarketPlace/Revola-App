import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/material_card.dart';
import '../../../catalog/presentation/controllers/catalog_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
        final categoriesAsync = ref.watch(categoriesProvider);
    final featuredAsync = ref.watch(featuredProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const BrandLogo(fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/catalog'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBlue,
        onRefresh: () async {
          ref.invalidate(featuredProductsProvider);
          ref.invalidate(categoriesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Spotlight Banner
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'REVOLA MARKETPLACE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Icon(Icons.verified, color: AppTheme.emeraldGreen, size: 18),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Adama Secondary & Reusable Materials',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connecting local buyers and sellers of surplus construction, timber, metals, and scrap goods.',
                      style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/catalog'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.explore_outlined, size: 16),
                      label: const Text('Explore Catalog', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              // 2. Categories Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Browse by Category',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                    ),
                    TextButton(
                      onPressed: () => context.push('/catalog'),
                      child: const Text('See All', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 46,
                child: categoriesAsync.when(
                  data: (categories) => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = categories[idx];
                      return ActionChip(
                        label: Text(cat.name),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.borderColor),
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                        onPressed: () {
                          ref.read(catalogFilterProvider.notifier).state =
                              ref.read(catalogFilterProvider).copyWith(selectedCategoryId: cat.id);
                          context.push('/catalog');
                        },
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: 20),

              // 3. Featured Materials Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Materials',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                    ),
                    TextButton(
                      onPressed: () => context.push('/catalog'),
                      child: const Text('View All', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              featuredAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: EmptyStateView(
                        icon: Icons.inventory_2_outlined,
                        title: 'No Materials Found',
                        message: 'Check back soon for freshly listed secondary items.',
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.76,
                    ),
                    itemCount: products.length > 8 ? 8 : products.length,
                    itemBuilder: (context, idx) {
                      final product = products[idx];
                      return MaterialCard(
                        product: product,
                        onTap: () => context.push('/material/${product.id}'),
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: LoadingIndicator(message: 'Loading materials...'),
                ),
                error: (err, _) => ErrorView(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(featuredProductsProvider),
                ),
              ),

              // 4. Trust & Escrow Guarantee
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppTheme.emeraldGreen, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Revola Escrow Protection',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF166534)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Payment is held securely until you receive and verify your materials in Adama.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF15803D)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
