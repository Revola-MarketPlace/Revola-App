import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/material_type_model.dart';
import '../../../../shared/models/product_model.dart';
import '../../data/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductRepository(client);
});

class CatalogFilterState {
  final String searchQuery;
  final String? selectedCategoryId;
  final String? selectedMaterialTypeId;
  final String? selectedCondition;
  final double? minPrice;
  final double? maxPrice;
  final bool inStockOnly;
  final String sortBy;

  CatalogFilterState({
    this.searchQuery = '',
    this.selectedCategoryId,
    this.selectedMaterialTypeId,
    this.selectedCondition,
    this.minPrice,
    this.maxPrice,
    this.inStockOnly = false,
    this.sortBy = '-createdAt',
  });

  CatalogFilterState copyWith({
    String? searchQuery,
    String? selectedCategoryId,
    String? selectedMaterialTypeId,
    String? selectedCondition,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    String? sortBy,
  }) {
    return CatalogFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedMaterialTypeId: selectedMaterialTypeId ?? this.selectedMaterialTypeId,
      selectedCondition: selectedCondition ?? this.selectedCondition,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

final catalogFilterProvider = StateProvider<CatalogFilterState>((ref) => CatalogFilterState());

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.watch(productRepositoryProvider).getCategories();
});

final materialTypesProvider = FutureProvider<List<MaterialTypeModel>>((ref) async {
  return ref.watch(productRepositoryProvider).getMaterialTypes();
});

final catalogProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final filter = ref.watch(catalogFilterProvider);

  return repo.getProducts(
    search: filter.searchQuery,
    categoryId: filter.selectedCategoryId,
    materialTypeId: filter.selectedMaterialTypeId,
    condition: filter.selectedCondition,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    inStock: filter.inStockOnly ? true : null,
    sort: filter.sortBy,
  );
});

final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts(limit: 12, sort: '-createdAt');
});
