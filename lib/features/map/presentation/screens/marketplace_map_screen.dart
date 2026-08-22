import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/map_place_model.dart';
import '../controllers/map_controller.dart';

class MarketplaceMapScreen extends ConsumerStatefulWidget {
  const MarketplaceMapScreen({super.key});

  @override
  ConsumerState<MarketplaceMapScreen> createState() => _MarketplaceMapScreenState();
}

class _MarketplaceMapScreenState extends ConsumerState<MarketplaceMapScreen> {
  MapPlaceModel? _selectedPlace;

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(mapPlacesProvider);
    final currentFilter = ref.watch(selectedMapFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace Map'),
      ),
      body: Stack(
        children: [
          // 1. FlutterMap OpenStreetMap
          placesAsync.when(
            data: (places) {
              return FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(AppConstants.adamaCenterLat, AppConstants.adamaCenterLng),
                  initialZoom: 13.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.revola.app',
                  ),
                  MarkerLayer(
                    markers: places.map((place) {
                      Color color = AppTheme.primaryBlue;
                      IconData icon = Icons.storefront;

                      if (place.placeType == 'DEPOT') {
                        color = AppTheme.accentOrange;
                        icon = Icons.warehouse;
                      } else if (place.placeType == 'OSM') {
                        color = AppTheme.emeraldGreen;
                        icon = Icons.recycling;
                      }

                      return Marker(
                        point: LatLng(place.latitude, place.longitude),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPlace = place),
                          child: CircleAvatar(
                            backgroundColor: color,
                            child: Icon(icon, color: Colors.white, size: 18),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(err.toString())),
          ),

          // 2. Filter Chips on Top
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'All Places', currentFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip('SELLER', 'Sellers', currentFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip('DEPOT', 'Admin Depots', currentFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip('OSM', 'Community Spots', currentFilter),
                ],
              ),
            ),
          ),

          // 3. Selected Place Callout Card
          if (_selectedPlace != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedPlace!.name,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _selectedPlace = null),
                        ),
                      ],
                    ),
                    Text(_selectedPlace!.address, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.push('/catalog'),
                      child: const Text('Browse Inventory'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, String label, String current) {
    final selected = current == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 12),
      onSelected: (val) {
        ref.read(selectedMapFilterProvider.notifier).state = val ? type : 'ALL';
      },
    );
  }
}
