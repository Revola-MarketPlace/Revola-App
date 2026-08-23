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
    Map<String, dynamic> prodJson = {};
    if (json['product'] is Map<String, dynamic>) {
      prodJson = json['product'];
    } else {
      prodJson = {
        'id': json['product']?.toString() ?? json['_id']?.toString() ?? '',
        'name': json['title'] ?? json['name'] ?? 'Material Item',
        'price': json['price'] ?? 0.0,
      };
    }

    String sId = '';
    if (json['seller'] is String) {
      sId = json['seller'];
    } else if (json['seller'] is Map) {
      sId = json['seller']['_id']?.toString() ?? json['seller']['id']?.toString() ?? '';
    }

    return OrderItemModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      product: ProductModel.fromJson(prodJson),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      sellerId: sId,
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
    final rawItems = (json['items'] as List?)
            ?.map((e) => OrderItemModel.fromJson(e is Map<String, dynamic> ? e : {}))
            .toList() ??
        [];

    List<double>? coords;
    if (json['deliveryLocation'] != null && json['deliveryLocation'] is Map && json['deliveryLocation']['coordinates'] is List) {
      coords = (json['deliveryLocation']['coordinates'] as List).map((e) => (e as num).toDouble()).toList();
    } else if (json['deliveryAddress'] != null && json['deliveryAddress'] is Map) {
      final dMap = json['deliveryAddress'] as Map;
      if (dMap['latitude'] != null && dMap['longitude'] != null) {
        coords = [(dMap['longitude'] as num).toDouble(), (dMap['latitude'] as num).toDouble()];
      }
    }

    String formattedAddress = 'Adama City';
    String? phone;

    if (json['deliveryAddress'] is Map) {
      final d = json['deliveryAddress'] as Map;
      final street = d['street']?.toString() ?? d['streetAddress']?.toString() ?? '';
      final subCity = d['subCity']?.toString() ?? '';
      final city = d['city']?.toString() ?? 'Adama';
      phone = d['phoneNumber']?.toString();
      final parts = [street, subCity, city].where((p) => p.trim().isNotEmpty).toList();
      if (parts.isNotEmpty) {
        formattedAddress = parts.join(', ');
      }
    } else if (json['deliveryAddress'] is String) {
      formattedAddress = json['deliveryAddress'];
    } else if (json['shippingAddress'] is Map) {
      final s = json['shippingAddress'] as Map;
      formattedAddress = s['street']?.toString() ?? s['city']?.toString() ?? 'Adama';
      phone = s['phoneNumber']?.toString();
    } else if (json['shippingAddress'] is String) {
      formattedAddress = json['shippingAddress'];
    }

    if (phone == null || phone.isEmpty) {
      phone = json['contactPhone']?.toString() ?? json['phoneNumber']?.toString();
    }

    return OrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? json['trackingNumber']?.toString() ?? (json['_id']?.toString().substring(0, 8).toUpperCase() ?? 'ORD'),
      items: rawItems,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      orderStatus: json['orderStatus']?.toString() ?? 'PENDING_PAYMENT',
      paymentStatus: json['paymentStatus']?.toString() ?? 'PENDING',
      paymentMethod: json['paymentMethod']?.toString() ?? 'CHAPA',
      deliveryAddress: formattedAddress,
      deliveryCoordinates: coords,
      contactPhone: phone,
      trackingNumber: json['trackingNumber']?.toString() ?? json['orderNumber']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
