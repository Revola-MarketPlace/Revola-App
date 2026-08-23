class MapPlaceModel {
  final String id;
  final String name;
  final String placeType; // 'SELLER', 'DEPOT', 'OSM'
  final double latitude;
  final double longitude;
  final String address;
  final String? phone;
  final List<String> materials;
  final String? openingHours;
  final bool isVerified;

  MapPlaceModel({
    required this.id,
    required this.name,
    required this.placeType,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.phone,
    this.materials = const [],
    this.openingHours,
    this.isVerified = false,
  });

  factory MapPlaceModel.fromJson(Map<String, dynamic> json) {
    double lat = 8.5400;
    double lng = 39.2700;

    if (json['coordinates'] != null && json['coordinates'] is List && (json['coordinates'] as List).length >= 2) {
      final coords = json['coordinates'] as List;
      lat = (coords[0] as num).toDouble();
      lng = (coords[1] as num).toDouble();
    } else if (json['location'] != null && json['location'] is Map && json['location']['coordinates'] is List) {
      final coords = json['location']['coordinates'] as List;
      lng = (coords[0] as num).toDouble();
      lat = (coords[1] as num).toDouble();
    }

    String pType = 'DEPOT';
    final rawType = json['placeType']?.toString().toUpperCase() ?? '';
    final rawSource = json['source']?.toString().toUpperCase() ?? '';
    if (rawType.contains('SELLER') || rawSource.contains('MARKETPLACE')) {
      pType = 'SELLER';
    } else if (rawType.contains('ADMIN') || rawSource.contains('ADMIN')) {
      pType = 'DEPOT';
    } else if (rawType.contains('OSM') || rawSource.contains('COMMUNITY') || rawSource.contains('EXTERNAL')) {
      pType = 'OSM';
    }

    final rawName = json['title']?.toString() ?? json['name']?.toString() ?? 'Adama Materials Depot';
    final rawAddress = json['address']?.toString() ?? json['location']?['address']?.toString() ?? 'Adama City';
    final phone = json['phone']?.toString() ?? '+251911223344';

    List<String> mats = [];
    if (json['materials'] is List) {
      mats = (json['materials'] as List).map((e) => e.toString()).toList();
    } else if (json['categories'] is List) {
      mats = (json['categories'] as List).map((e) => e.toString()).toList();
    }
    if (mats.isEmpty) mats = ['Salvaged Materials', 'Reclaimed Goods'];

    return MapPlaceModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: rawName,
      placeType: pType,
      latitude: lat,
      longitude: lng,
      address: rawAddress,
      phone: phone,
      materials: mats,
      openingHours: json['openingHours']?.toString() ?? '8:00 AM - 6:00 PM',
      isVerified: json['isVerified'] ?? true,
    );
  }
}
