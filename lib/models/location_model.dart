class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double speed;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    required this.speed,
    required this.timestamp,
  });
}

class Geofence {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius; // in meters

  Geofence({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });
}