import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:alzheimer_navigation_app/utils/constants.dart';

class FullScreenMap extends StatelessWidget {
  final LatLng currentLocation;
  final LatLng homeLocation;
  final List<LatLng> routePoints;
  final double distanceToHome;

  const FullScreenMap({
    super.key,
    required this.currentLocation,
    required this.homeLocation,
    required this.routePoints,
    required this.distanceToHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Full Screen Map'),
            Text(
              'Distance to home: ${(distanceToHome / 1000).toStringAsFixed(1)} km',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          center: currentLocation,
          zoom: 14.0,
          interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        children: [
          TileLayer(
            urlTemplate: AppConstants.openStreetMapUrl,
            userAgentPackageName: 'com.example.alzheimer_navigation_app',
          ),
          // Draw realistic route line
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  color: AppConstants.primaryColor.withOpacity(0.8),
                  strokeWidth: 8,
                  borderStrokeWidth: 2,
                  borderColor: Colors.white,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              // Home Marker
              Marker(
                point: homeLocation,
                width: 50,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              // Current Location Marker
              Marker(
                point: currentLocation,
                width: 60,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Fit map to show entire route
              final mapState = MapController();
              final LatLngBounds routeBounds = LatLngBounds.fromPoints(routePoints);
              mapState.fitBounds(
                routeBounds,
                options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
              );
            },
            backgroundColor: AppConstants.primaryColor,
            mini: true,
            child: const Icon(Icons.zoom_out_map, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            backgroundColor: AppConstants.primaryColor,
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
}