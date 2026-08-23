import 'product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final double priceAtAddition;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.priceAtAddition,
  });

  double get totalPrice => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      product: ProductModel.fromJson(
        json['product'] is Map<String, dynamic> ? json['product'] : {},
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      priceAtAddition:
          (json['priceAtAddition'] as num?)?.toDouble() ??
          (json['product']?['price'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

class CartModel {
  final String id;
  final List<CartItemModel> items;

  CartModel({required this.id, required this.items});

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final list =
        (json['items'] as List?)
            ?.map((e) => CartItemModel.fromJson(e))
            .toList() ??
        [];
    return CartModel(id: json['_id'] ?? json['id'] ?? '', items: list);
  }
}
