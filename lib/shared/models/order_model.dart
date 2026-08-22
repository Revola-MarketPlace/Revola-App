import 'product_model.dart';

class OrderItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final double price;
  final String sellerId;

  OrderItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    required this.sellerId,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      product: ProductModel.fromJson(json['product'] is Map<String, dynamic> ? json['product'] : {'name': json['title'] ?? 'Item', 'price': json['price']}),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      sellerId: json['seller'] is String ? json['seller'] : json['seller']?['_id'] ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String orderStatus; // 'PENDING_PAYMENT', 'CONFIRMED', 'OUT_FOR_DELIVERY', 'DELIVERED', 'COMPLETED', 'CANCELLED'
  final String paymentStatus; // 'PENDING', 'PAID', 'PENDING_VERIFICATION', 'FAILED'
  final String paymentMethod; // 'CHAPA', 'TELEBIRR', 'BANK_TRANSFER', 'MOCK'
  final String? deliveryAddress;
  final List<double>? deliveryCoordinates;
  final String? contactPhone;
  final String? trackingNumber;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    this.deliveryAddress,
    this.deliveryCoordinates,
    this.contactPhone,
    this.trackingNumber,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?)?.map((e) => OrderItemModel.fromJson(e)).toList() ?? [];
    List<double>? coords;
    if (json['deliveryLocation'] != null && json['deliveryLocation']['coordinates'] != null) {
      coords = (json['deliveryLocation']['coordinates'] as List).map((e) => (e as num).toDouble()).toList();
    }

    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? json['_id']?.toString().substring(0, 8).toUpperCase() ?? 'ORD',
      items: rawItems,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      orderStatus: json['orderStatus'] ?? 'PENDING_PAYMENT',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? 'CHAPA',
      deliveryAddress: json['shippingAddress']?['street'] ?? json['deliveryAddress'] ?? 'Adama',
      deliveryCoordinates: coords,
      contactPhone: json['shippingAddress']?['phoneNumber'] ?? json['contactPhone'],
      trackingNumber: json['trackingNumber'] ?? json['orderNumber'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
