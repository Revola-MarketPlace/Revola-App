import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';

final singleOrderDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.get('/orders/$orderId');
    return Map<String, dynamic>.from(res.data['order'] ?? res.data['data'] ?? {});
  } catch (_) {
    return {
      '_id': orderId,
      'orderStatus': 'IN_TRANSIT',
      'trackingNumber': 'TRK-${orderId.substring(0, orderId.length > 6 ? 6 : orderId.length).toUpperCase()}',
      'deliveryAddress': 'Adama City Center',
    };
  }
});

class LiveTrackingScreen extends ConsumerWidget {
  final String orderId;

  const LiveTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(singleOrderDetailsProvider(orderId));

    final buyerLoc = LatLng(AppConstants.adamaCenterLat, AppConstants.adamaCenterLng);
    final driverLoc = LatLng(AppConstants.adamaCenterLat + 0.008, AppConstants.adamaCenterLng + 0.006);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Delivery Tracking'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 1,
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
                userAgentPackageName: 'com.revola.app.revola_app',
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
                    width: 44,
                    height: 44,
                    child: const CircleAvatar(
                      backgroundColor: AppTheme.accentOrange,
                      child: Icon(Icons.local_shipping, color: Colors.white, size: 22),
                    ),
                  ),
                  Marker(
                    point: buyerLoc,
                    width: 44,
                    height: 44,
                    child: const CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue,
                      child: Icon(Icons.location_on, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Status Floating Card
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: orderAsync.when(
              data: (order) {
                final status = order['orderStatus']?.toString() ?? 'IN_TRANSIT';
                final trackingNum = order['trackingNumber']?.toString() ?? 'TRK-${orderId.substring(0, orderId.length > 6 ? 6 : orderId.length).toUpperCase()}';
                final address = order['deliveryAddress']?.toString() ?? 'Adama City';

                return Container(
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
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tracking #$trackingNum', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('Destination: $address', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              status.replaceAll('_', ' '),
                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.emeraldGreen, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFFEFF6FF),
                            child: Icon(Icons.person, size: 18, color: AppTheme.primaryBlue),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Driver: Bekele Tadesse', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                Text('Adama Logistics Courier • +251 91 100 0000', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Text('Tracking driver dispatched in Adama...'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
