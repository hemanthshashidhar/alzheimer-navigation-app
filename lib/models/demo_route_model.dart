import 'package:latlong2/latlong.dart';

class DemoRoute {
  final String id;
  final String name;
  final LatLng start;
  final LatLng destination;
  final String context;

  DemoRoute({
    required this.id,
    required this.name,
    required this.start,
    required this.destination,
    required this.context,
  });
}
