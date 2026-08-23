import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/dispute_model.dart';
import '../../../shared/models/order_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return OrderRepository(client);
});

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  Future<double> estimateDeliveryFee({
    required double latitude,
    required double longitude,
    int? totalQuantity,
    List<String>? productIds,
  }) async {
    try {
      final res = await _apiClient.post('/orders/estimate-delivery-fee', data: {
        'address': {
          'latitude': latitude,
          'longitude': longitude,
          'city': 'Adama',
        },
        'totalQuantity': totalQuantity ?? 1,
      });
      final fee = res.data['deliveryFee'] ?? res.data['data']?['deliveryFee'];
      return (fee as num?)?.toDouble() ?? 150.0;
    } catch (_) {
      return 150.0;
    }
  }

  Future<Map<String, dynamic>> checkout({
    required Map<String, dynamic> deliveryAddress,
    String paymentMethod = 'CHAPA',
    String? deliveryNotes,
  }) async {
    final res = await _apiClient.post('/orders/checkout', data: {
      'paymentMethod': 'CHAPA',
      'deliveryAddress': deliveryAddress,
      if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
    });

    final orderJson = res.data['order'] ?? res.data['data'] ?? res.data;
    final paymentUrl = res.data['paymentUrl'] ?? res.data['checkoutUrl'] ?? '';

    return {
      'order': orderJson,
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
