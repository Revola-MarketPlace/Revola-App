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

  factory SellerProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SellerProfile();

    List<double>? coords;
    if (json['shopLocation'] != null && json['shopLocation'] is Map) {
      final loc = Map<String, dynamic>.from(json['shopLocation'] as Map);
      if (loc['coordinates'] is List) {
        coords = (loc['coordinates'] as List)
            .map((e) => (e as num?)?.toDouble() ?? 0.0)
            .toList();
      }
    }
    return SellerProfile(
      shopName: json['shopName']?.toString(),
      shopDescription: json['shopDescription']?.toString(),
      shopAddress: json['shopAddress']?.toString(),
      coordinates: coords,
      bankName: json['bankName']?.toString(),
      accountHolder: json['accountHolder']?.toString(),
      accountNumber: json['accountNumber']?.toString(),
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

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return UserModel(id: '', name: 'User', email: '', role: 'BUYER');
    }

    List<String> userRoles = ['BUYER'];
    if (json['roles'] != null && json['roles'] is List) {
      userRoles = (json['roles'] as List).map((e) => e?.toString() ?? 'BUYER').toList();
    } else if (json['role'] != null) {
      userRoles = [json['role'].toString()];
    }

    SellerProfile? profile;
    if (json['sellerProfile'] != null && json['sellerProfile'] is Map) {
      profile = SellerProfile.fromJson(Map<String, dynamic>.from(json['sellerProfile'] as Map));
    }

    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'BUYER',
      roles: userRoles,
      isSellerApproved: json['isSellerApproved'] == true,
      phoneNumber: json['phoneNumber']?.toString(),
      sellerProfile: profile,
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
