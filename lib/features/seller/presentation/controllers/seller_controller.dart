import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/models/product_model.dart';
import '../../data/seller_repository.dart';

final sellerRepositoryProvider = Provider<SellerRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return SellerRepository(client);
});

final sellerProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  return ref.watch(sellerRepositoryProvider).getMyProducts();
});

final sellerPayoutsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(sellerRepositoryProvider).getMyPayouts();
});
