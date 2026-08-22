class SellerProfile {
  final String? shopName;
  final String? shopDescription;
  final String? shopAddress;
  final List<double>? coordinates; // [lng, lat]
  final String? bankName;
  final String? accountHolder;
  final String? accountNumber;

  SellerProfile({
    this.shopName,
    this.shopDescription,
    this.shopAddress,
    this.coordinates,
    this.bankName,
    this.accountHolder,
    this.accountNumber,
  });

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    List<double>? coords;
    if (json['shopLocation'] != null && json['shopLocation']['coordinates'] != null) {
      coords = (json['shopLocation']['coordinates'] as List).map((e) => (e as num).toDouble()).toList();
    }
    return SellerProfile(
      shopName: json['shopName'],
      shopDescription: json['shopDescription'],
      shopAddress: json['shopAddress'],
      coordinates: coords,
      bankName: json['bankName'],
      accountHolder: json['accountHolder'],
      accountNumber: json['accountNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'shopDescription': shopDescription,
      'shopAddress': shopAddress,
      'bankName': bankName,
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      if (coordinates != null)
        'shopLocation': {
          'type': 'Point',
          'coordinates': coordinates,
          'address': shopAddress ?? '',
        },
    };
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'BUYER', 'SELLER', 'ADMIN', 'STAFF'
  final List<String> roles;
  final bool isSellerApproved;
  final String? phoneNumber;
  final SellerProfile? sellerProfile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.roles = const [],
    this.isSellerApproved = false,
    this.phoneNumber,
    this.sellerProfile,
  });

  bool get isSeller => role == 'SELLER' || roles.contains('SELLER');
  bool get isAdmin => role == 'ADMIN';
  bool get isStaff => role == 'STAFF' || role == 'ADMIN';
  bool get isBuyer => role == 'BUYER';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'BUYER',
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [json['role'] ?? 'BUYER'],
      isSellerApproved: json['isSellerApproved'] ?? false,
      phoneNumber: json['phoneNumber'],
      sellerProfile: json['sellerProfile'] != null ? SellerProfile.fromJson(json['sellerProfile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'roles': roles,
      'isSellerApproved': isSellerApproved,
      'phoneNumber': phoneNumber,
      if (sellerProfile != null) 'sellerProfile': sellerProfile!.toJson(),
    };
  }
}
