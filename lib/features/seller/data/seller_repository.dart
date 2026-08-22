import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/product_model.dart';

class SellerRepository {
  final ApiClient _apiClient;

  SellerRepository(this._apiClient);

  Future<List<ProductModel>> getMyProducts() async {
    final res = await _apiClient.get(ApiEndpoints.mySellerProducts);
    final list = res.data['products'] ?? res.data['data'] ?? [];
    return (list as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final res = await _apiClient.post(ApiEndpoints.products, data: data);
    final json = res.data['product'] ?? res.data['data'] ?? res.data;
    return ProductModel.fromJson(json);
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    final res = await _apiClient.put('${ApiEndpoints.products}/$id', data: data);
    final json = res.data['product'] ?? res.data['data'] ?? res.data;
    return ProductModel.fromJson(json);
  }

  Future<void> deleteProduct(String id) async {
    await _apiClient.delete('${ApiEndpoints.products}/$id');
  }

  Future<List<dynamic>> getMyPayouts() async {
    final res = await _apiClient.get(ApiEndpoints.myPayouts);
    return res.data['payouts'] ?? res.data['data'] ?? [];
  }
}
