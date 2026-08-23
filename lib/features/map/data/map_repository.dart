import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/map_place_model.dart';

class MapRepository {
  final ApiClient _apiClient;

  MapRepository(this._apiClient);

  Future<List<MapPlaceModel>> getPlaces({String? type}) async {
    final query = <String, dynamic>{};
    if (type != null && type != 'ALL') query['type'] = type;
    final res = await _apiClient.get(ApiEndpoints.mapPlaces, queryParameters: query);
    final list = res.data['places'] ?? res.data['data'] ?? [];
    return (list as List).map((e) => MapPlaceModel.fromJson(e)).toList();
  }
}
