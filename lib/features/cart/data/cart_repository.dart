import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/cart_model.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository(this._apiClient);

  Future<CartModel> getCart() async {
    final res = await _apiClient.get(ApiEndpoints.cart);
    final json = res.data['cart'] ?? res.data['data'] ?? res.data;
    return CartModel.fromJson(json);
  }

  Future<CartModel> addToCart(String productId, int quantity) async {
    final res = await _apiClient.post(ApiEndpoints.cartItems, data: {
      'productId': productId,
      'quantity': quantity,
    });
    final json = res.data['cart'] ?? res.data['data'] ?? res.data;
    return CartModel.fromJson(json);
  }

  Future<CartModel> updateQuantity(String itemId, int quantity) async {
    final res = await _apiClient.put('${ApiEndpoints.cartItems}/$itemId', data: {
      'quantity': quantity,
    });
    final json = res.data['cart'] ?? res.data['data'] ?? res.data;
    return CartModel.fromJson(json);
  }

  Future<CartModel> removeFromCart(String itemId) async {
    final res = await _apiClient.delete('${ApiEndpoints.cartItems}/$itemId');
    final json = res.data['cart'] ?? res.data['data'] ?? res.data;
    return CartModel.fromJson(json);
  }
}
