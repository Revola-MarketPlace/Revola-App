import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/material_type_model.dart';
import '../../../shared/models/product_model.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<List<ProductModel>> getProducts({
    String? search,
    String? categoryId,
    String? materialTypeId,
    String? condition,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    String? sort,
    int limit = 50,
  }) async {
    final query = <String, dynamic>{'limit': limit};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (categoryId != null && categoryId.isNotEmpty) query['category'] = categoryId;
    if (materialTypeId != null && materialTypeId.isNotEmpty) query['materialType'] = materialTypeId;
    if (condition != null && condition.isNotEmpty) query['condition'] = condition;
    if (minPrice != null) query['minPrice'] = minPrice;
    if (maxPrice != null) query['maxPrice'] = maxPrice;
    if (inStock == true) query['inStock'] = 'true';
    if (sort != null) query['sort'] = sort;

    final res = await _apiClient.get(ApiEndpoints.products, queryParameters: query);
    final list = res.data['products'] ?? res.data['data'] ?? [];
    return (list as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final res = await _apiClient.get('${ApiEndpoints.products}/$id');
    final json = res.data['product'] ?? res.data['data'] ?? res.data;
    return ProductModel.fromJson(json);
  }

  Future<List<CategoryModel>> getCategories() async {
    final res = await _apiClient.get(ApiEndpoints.categories);
    final list = res.data['categories'] ?? res.data['data'] ?? [];
    return (list as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<List<MaterialTypeModel>> getMaterialTypes() async {
    final res = await _apiClient.get(ApiEndpoints.materialTypes);
    final list = res.data['materialTypes'] ?? res.data['data'] ?? [];
    return (list as List).map((e) => MaterialTypeModel.fromJson(e)).toList();
  }
}
