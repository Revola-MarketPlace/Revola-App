import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/models/order_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return OrderRepository(client);
});

final buyerOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.isLoading || !auth.isAuthenticated || auth.token == null || auth.token!.isEmpty) {
    return [];
  }
  return ref.watch(orderRepositoryProvider).getMyOrders();
});

final sellerOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.isLoading || !auth.isAuthenticated || auth.token == null || auth.token!.isEmpty) {
    return [];
  }
  return ref.watch(orderRepositoryProvider).getSellerOrders();
});
