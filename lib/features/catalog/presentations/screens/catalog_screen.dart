import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/material_card.dart';
import '../controllers/catalog_controller.dart';
import 'widgets/filter_bottom_sheet.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(catalogProductsProvider);
    final filter = ref.watch(catalogFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const FilterBottomSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Box & Active Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: [
                CustomTextField(
                  hintText: 'Search wood pallets, steel, plastic barrels...',
                  controller: _searchCtrl,
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(catalogFilterProvider.notifier).state =
                                ref.read(catalogFilterProvider).copyWith(searchQuery: '');
                          },
                        )
                      : null,
                  onChanged: (val) {
                    ref.read(catalogFilterProvider.notifier).state =
                        ref.read(catalogFilterProvider).copyWith(searchQuery: val.trim());
                  },
                ),
                if (filter.selectedCategoryId != null || filter.selectedCondition != null || filter.inStockOnly) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Filters applied', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          ref.read(catalogFilterProvider.notifier).state = CatalogFilterState();
                          _searchCtrl.clear();
                        },
                        child: const Text('Clear All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderColor),

          // Products Grid
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primaryBlue,
              onRefresh: () async => ref.invalidate(catalogProductsProvider),
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.search_off,
                      title: 'No Matching Materials',
                      message: 'Try adjusting your search query or reset your filters.',
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.76,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, idx) {
                      final product = products[idx];
                      return MaterialCard(
                        product: product,
                        onTap: () => context.push('/material/${product.id}'),
                      );
                    },
                  );
                },
                loading: () => const LoadingIndicator(message: 'Searching materials...'),
                error: (err, _) => ErrorView(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(catalogProductsProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
