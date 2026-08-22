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
    final res = await _apiClient.post(ApiEndpoints.estimateDeliveryFee, data: {
      'latitude': latitude,
      'longitude': longitude,
      'productIds': productIds,
    });
    return res.data;
  }

  Future<OrderModel> checkout({
    required String paymentMethod,
    required String deliveryAddress,
    required List<double> deliveryCoordinates,
    required String contactPhone,
    String? deliveryNotes,
  }) async {
    final res = await _apiClient.post(ApiEndpoints.checkout, data: {
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress,
      'deliveryCoordinates': deliveryCoordinates,
      'contactPhone': contactPhone,
      if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
    });
    final json = res.data['order'] ?? res.data['data'] ?? res.data;
    return OrderModel.fromJson(json);
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
