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

    if (json['location'] != null && json['location']['coordinates'] != null) {
      final coords = json['location']['coordinates'] as List;
      lng = (coords[0] as num).toDouble();
      lat = (coords[1] as num).toDouble();
    }

    return MapPlaceModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Place',
      placeType: json['placeType'] ?? (json['source'] == 'COMMUNITY_OSM' ? 'OSM' : 'DEPOT'),
      latitude: lat,
      longitude: lng,
      address: json['address'] ?? json['location']?['address'] ?? 'Adama',
      phone: json['phone'],
      materials: json['materials'] != null ? List<String>.from(json['materials']) : [],
      openingHours: json['openingHours'],
      isVerified: json['isVerified'] ?? false,
    );
  }
}
