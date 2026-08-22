import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class LiveTrackingScreen extends StatelessWidget {
  final String orderId;

  const LiveTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final buyerLoc = LatLng(AppConstants.adamaCenterLat, AppConstants.adamaCenterLng);
    final driverLoc = LatLng(AppConstants.adamaCenterLat + 0.008, AppConstants.adamaCenterLng + 0.006);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Delivery Tracking'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: driverLoc,
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.revola.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [driverLoc, buyerLoc],
                    strokeWidth: 4,
                    color: AppTheme.primaryBlue,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: driverLoc,
                    width: 40,
                    height: 40,
                    child: const CircleAvatar(
                      backgroundColor: AppTheme.accentOrange,
                      child: Icon(Icons.local_shipping, color: Colors.white, size: 20),
                    ),
                  ),
                  Marker(
                    point: buyerLoc,
                    width: 40,
                    height: 40,
                    child: const CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue,
                      child: Icon(Icons.location_on, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Status Floating Card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Driver on Route', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Text('Est: 15 mins', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.emeraldGreen)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Delivery driver Bekele is transporting your materials inside Adama.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
