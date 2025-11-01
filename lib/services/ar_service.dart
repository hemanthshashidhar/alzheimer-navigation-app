import 'dart:math';
import 'package:latlong2/latlong.dart';

class ARService {
  static final ARService _instance = ARService._internal();
  factory ARService() => _instance;
  ARService._internal();

  /// Calculate bearing from one location to another (in degrees, 0-360)
  /// 0° = North, 90° = East, 180° = South, 270° = West
  double calculateBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * pi / 180;
    final lat2 = to.latitude * pi / 180;
    final dLng = (to.longitude - from.longitude) * pi / 180;

    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final bearing = atan2(y, x);

    // Convert to degrees and normalize to 0-360
    return (bearing * 180 / pi + 360) % 360;
  }

  /// Calculate distance between two locations (in meters)
  double calculateDistance(LatLng from, LatLng to) {
    const Distance distance = Distance();
    return distance(from, to);
  }

  /// Format distance for display (e.g., "250m" or "1.2 km")
  String formatDistanceDisplay(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Calculate relative bearing (difference between device heading and target bearing)
  /// Returns angle in degrees (-180 to 180)
  /// Negative = turn left, Positive = turn right
  double calculateRelativeBearing(double deviceHeading, double targetBearing) {
    double diff = targetBearing - deviceHeading;

    // Normalize to -180 to 180
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    return diff;
  }

  /// Get cardinal direction from bearing (N, NE, E, SE, S, SW, W, NW)
  String getCardinalDirection(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}
