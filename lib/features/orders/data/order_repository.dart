import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/dispute_model.dart';
import '../../../shared/models/order_model.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  Future<Map<String, dynamic>> estimateDeliveryFee({
    required double latitude,
    required double longitude,
    required List<String> productIds,
  }) async {
    final res = await _apiClient.post('/orders/estimate-delivery-fee', data: {
      'latitude': latitude,
      'longitude': longitude,
      'productIds': productIds,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> checkout({
    required String paymentMethod,
    required String street,
    required double latitude,
    required double longitude,
    required String contactPhone,
    String? deliveryNotes,
  }) async {
    final res = await _apiClient.post('/orders/checkout', data: {
      'paymentMethod': 'CHAPA',
      'deliveryAddress': {
        'street': street,
        'subCity': 'Bole',
        'city': 'Adama',
        'phoneNumber': contactPhone,
        'latitude': latitude,
        'longitude': longitude,
      },
      if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
    });

    final orderJson = res.data['order'] ?? res.data['data'] ?? res.data;
    final order = OrderModel.fromJson(orderJson);
    final paymentUrl = res.data['paymentUrl'] ?? res.data['checkoutUrl'] ?? '';

    return {
      'order': order,
      'paymentUrl': paymentUrl,
    };
  }

  Future<List<OrderModel>> getMyOrders() async {
    final res = await _apiClient.get(ApiEndpoints.myBuyerOrders);
    final list = res.data['orders'] ?? res.data['data'] ?? [];
    return (list as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<List<OrderModel>> getSellerOrders() async {
    final res = await _apiClient.get(ApiEndpoints.mySellerOrders);
    final list = res.data['orders'] ?? res.data['data'] ?? [];
    return (list as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> getOrderByTracking(String trackingNumber) async {
    final res = await _apiClient.get('${ApiEndpoints.trackingByNumber}/$trackingNumber');
    final json = res.data['order'] ?? res.data['data'] ?? res.data;
    return OrderModel.fromJson(json);
  }

  Future<Map<String, dynamic>> getDeliveryStatus(String orderId) async {
    final res = await _apiClient.get('${ApiEndpoints.deliveryByOrder}/$orderId');
    return res.data;
  }

  Future<void> cancelOrder(String orderId) async {
    await _apiClient.put('${ApiEndpoints.myBuyerOrders}/$orderId/cancel');
  }

  Future<DisputeModel> submitDispute({
    required String orderId,
    required String reason,
    required String description,
  }) async {
    final res = await _apiClient.post(ApiEndpoints.disputes, data: {
      'order': orderId,
      'reason': reason,
      'description': description,
    });
    final json = res.data['dispute'] ?? res.data['data'] ?? res.data;
    return DisputeModel.fromJson(json);
  }

  Future<List<DisputeModel>> getMyDisputes() async {
    final res = await _apiClient.get(ApiEndpoints.myDisputes);
    final list = res.data['disputes'] ?? res.data['data'] ?? [];
    return (list as List).map((e) => DisputeModel.fromJson(e)).toList();
  }
}
