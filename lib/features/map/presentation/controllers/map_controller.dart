import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/models/map_place_model.dart';
import '../../data/map_repository.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return MapRepository(client);
});

final selectedMapFilterProvider = StateProvider<String>((ref) => 'ALL');

final mapPlacesProvider = FutureProvider<List<MapPlaceModel>>((ref) async {
  final filter = ref.watch(selectedMapFilterProvider);
  return ref.watch(mapRepositoryProvider).getPlaces(type: filter);
});
