import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  static final RouteService _instance = RouteService._internal();
  factory RouteService() => _instance;
  RouteService._internal();

  // Using OpenRouteService API for realistic routing
  static const String _apiKey = 'your_api_key_here'; // You can get free API key from openrouteservice.org
  static const String _baseUrl = 'https://api.openrouteservice.org/v2/directions';

  // For demo purposes, we'll use a free alternative - OSRM (Open Source Routing Machine)
  static const String _osrmBaseUrl = 'https://router.project-osrm.org/route/v1';

  Future<List<LatLng>> getRouteCoordinates(LatLng start, LatLng end) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_osrmBaseUrl/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          // Convert coordinates to LatLng objects
          return coordinates.map<LatLng>((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();
        }
      }
      
      // Fallback: return a realistic-looking route with curves
      return _generateRealisticRoute(start, end);
    } catch (e) {
      print('Error fetching route: $e');
      // Fallback to realistic route generation
      return _generateRealisticRoute(start, end);
    }
  }

  List<LatLng> _generateRealisticRoute(LatLng start, LatLng end) {
    final List<LatLng> routePoints = [];
    
    // Add start point
    routePoints.add(start);
    
    // Calculate intermediate points to create a realistic curved route
    final double latDiff = end.latitude - start.latitude;
    final double lngDiff = end.longitude - start.longitude;
    
    // Create 10 intermediate points with slight curves
    for (int i = 1; i < 10; i++) {
      final double progress = i / 10.0;
      
      // Add some curvature to make it look like a real road
      double curveFactor = 0.0;
      if (progress > 0.3 && progress < 0.7) {
        curveFactor = 0.0002 * (1 - (progress - 0.5).abs() * 4);
      }
      
      final double lat = start.latitude + latDiff * progress + curveFactor;
      final double lng = start.longitude + lngDiff * progress - curveFactor;
      
      routePoints.add(LatLng(lat, lng));
    }
    
    // Add end point
    routePoints.add(end);
    
    return routePoints;
  }

  // Get route instructions (for the directions dialog)
  Future<List<String>> getRouteInstructions(LatLng start, LatLng end) async {
    // For demo purposes, return some realistic instructions
    return [
      'Head north on Main Street for 200 meters',
      'Turn right onto Park Avenue',
      'Continue straight for 150 meters',
      'Turn left onto Oak Street',
      'Your home will be on the right',
    ];
  }

  // Calculate realistic distance (not straight line)
  Future<double> calculateRouteDistance(LatLng start, LatLng end) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_osrmBaseUrl/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=false',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final distance = routes[0]['distance'] as double;
          return distance; // Returns distance in meters
        }
      }
    } catch (e) {
      print('Error calculating route distance: $e');
    }
    
    // Fallback: calculate straight line distance and add some extra for realism
    final Distance distance = Distance();
    final double straightDistance = distance(start, end);
    return straightDistance * 1.3; // Add 30% for realistic road distance
  }
}