import 'category_model.dart';
import 'material_type_model.dart';

class ProductLocation {
  final String subCity;
  final String city;
  final List<double>? coordinates; // [lng, lat]

  ProductLocation({
    required this.subCity,
    required this.city,
    this.coordinates,
  });

  factory ProductLocation.fromJson(Map<String, dynamic> json) {
    List<double>? coords;
    if (json['coordinates'] != null && json['coordinates'] is List) {
      coords = (json['coordinates'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
    }
    return ProductLocation(
      subCity: json['subCity'] ?? 'Adama',
      city: json['city'] ?? 'Adama',
      coordinates: coords,
    );
  }

  Map<String, dynamic> toJson() => {
    'subCity': subCity,
    'city': city,
    if (coordinates != null) 'coordinates': coordinates,
  };
}

class ProductSeller {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? shopName;
  final String? shopAddress;
  final List<double>? shopCoordinates;

  ProductSeller({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.shopName,
    this.shopAddress,
    this.shopCoordinates,
  });

  factory ProductSeller.fromJson(Map<String, dynamic> json) {
    List<double>? coords;
    if (json['sellerProfile'] != null &&
        json['sellerProfile']['shopLocation'] != null &&
        json['sellerProfile']['shopLocation']['coordinates'] != null) {
      coords = (json['sellerProfile']['shopLocation']['coordinates'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
    }
    return ProductSeller(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Seller',
      phoneNumber: json['phoneNumber'],
      shopName: json['sellerProfile']?['shopName'] ?? json['name'] ?? 'Shop',
      shopAddress: json['sellerProfile']?['shopAddress'] ?? 'Adama',
      shopCoordinates: coords,
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String condition; // 'Like New', 'Good', 'Fair', 'Used'
  final List<String> images;
  final CategoryModel? category;
  final MaterialTypeModel? materialType;
  final ProductSeller? seller;
  final ProductLocation? location;
  final String approvalStatus; // 'PENDING_APPROVAL', 'APPROVED', 'REJECTED'
  final double rating;
  final int reviewsCount;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.condition,
    required this.images,
    this.category,
    this.materialType,
    this.seller,
    this.location,
    this.approvalStatus = 'APPROVED',
    this.rating = 5.0,
    this.reviewsCount = 0,
    this.createdAt,
  });

  bool get inStock => quantity > 0;
  String get primaryImage {
    if (images.isNotEmpty && images.first.trim().isNotEmpty) {
      return images.first;
    }
    final catName = (category?.name ?? '').toLowerCase();
    final prodName = name.toLowerCase();

    if (catName.contains('wood') ||
        prodName.contains('wood') ||
        prodName.contains('pallet') ||
        prodName.contains('timber')) {
      return 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=600&auto=format&fit=crop&q=80';
    }
    if (catName.contains('metal') ||
        prodName.contains('steel') ||
        prodName.contains('pipe') ||
        prodName.contains('sheet')) {
      return 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=600&auto=format&fit=crop&q=80';
    }
    if (catName.contains('electronic') ||
        prodName.contains('circuit') ||
        prodName.contains('wire') ||
        prodName.contains('motor')) {
      return 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=600&auto=format&fit=crop&q=80';
    }
    if (catName.contains('furnit') ||
        prodName.contains('desk') ||
        prodName.contains('chair') ||
        prodName.contains('door')) {
      return 'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?w=600&auto=format&fit=crop&q=80';
    }
    if (catName.contains('plastic') ||
        prodName.contains('plastic') ||
        prodName.contains('barrel') ||
        prodName.contains('crate')) {
      return 'https://images.unsplash.com/photo-1584473457406-6240486418e9?w=600&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1541888946425-d0fbb18086f6?w=600&auto=format&fit=crop&q=80';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    CategoryModel? cat;
    if (json['category'] != null) {
      if (json['category'] is Map<String, dynamic>) {
        cat = CategoryModel.fromJson(json['category']);
      } else if (json['category'] is String) {
        cat = CategoryModel(id: json['category'], name: 'Category');
      }
    }

    MaterialTypeModel? mat;
    if (json['materialType'] != null) {
      if (json['materialType'] is Map<String, dynamic>) {
        mat = MaterialTypeModel.fromJson(json['materialType']);
      } else if (json['materialType'] is String) {
        mat = MaterialTypeModel(id: json['materialType'], name: 'Material');
      }
    }

    ProductSeller? sel;
    if (json['seller'] != null && json['seller'] is Map<String, dynamic>) {
      sel = ProductSeller.fromJson(json['seller']);
    }

    ProductLocation? loc;
    if (json['location'] != null && json['location'] is Map<String, dynamic>) {
      loc = ProductLocation.fromJson(json['location']);
    }

    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      condition: json['condition'] ?? 'Good',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      category: cat,
      materialType: mat,
      seller: sel,
      location: loc,
      approvalStatus: json['approvalStatus'] ?? 'APPROVED',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
