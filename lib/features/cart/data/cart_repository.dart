import '../../../core/network/api_client.dart';
import '../../../shared/models/cart_model.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository(this._apiClient);

  Future<CartModel> getCart() async {
    final res = await _apiClient.get('/cart');
    final json = res.data['cart'] ?? res.data['data'] ?? res.data;
    return CartModel.fromJson(json);
  }

  Future<CartModel> addToCart(String productId, int quantity) async {
    final res = await _apiClient.post('/cart/add', data: {
      'productId': productId,
      'quantity': quantity,
    });
    final json = res.data['cart'] ?? res.data['data'] ?? res.data;
    return CartModel.fromJson(json);
  }

  Future<CartModel> updateQuantity(String productId, int quantity) async {
    final res = await _apiClient.put('/cart/update', data: {
      'productId': productId,
      'quantity': quantity,
    });
    final json = res.data['cart'] ?? res.data['data'] ?? res.data;
    return CartModel.fromJson(json);
  }

  Future<CartModel> removeFromCart(String productId) async {
    final res = await _apiClient.post('/cart/remove', data: {
      'productId': productId,
    });
    final json = res.data['cart'] ?? res.data['data'] ?? res.data;
    return CartModel.fromJson(json);
  }

  Future<void> clearCart() async {
    try {
      await _apiClient.delete('/cart');
    } catch (_) {}
  }
}
