import 'package:latlong2/latlong.dart';
import 'package:alzheimer_navigation_app/models/demo_route_model.dart';

final List<DemoRoute> demoRoutes = [
  DemoRoute(
    id: '1',
    name: 'Home Route',
    start: const LatLng(12.9352, 77.6245),
    destination: const LatLng(12.9716, 77.5946),
    context: 'Existing baseline route (~850m, NW)',
  ),
  DemoRoute(
    id: '2',
    name: 'Park Walk',
    start: const LatLng(12.9352, 77.6245),
    destination: const LatLng(12.9420, 77.6350),
    context: 'Very short, right turn (~150m, NE)',
  ),
  DemoRoute(
    id: '3',
    name: 'Grocery Store',
    start: const LatLng(12.9352, 77.6245),
    destination: const LatLng(12.9280, 77.6400),
    context: 'Short, shopping area (~320m, SE)',
  ),
  DemoRoute(
    id: '4',
    name: 'Hospital Route',
    start: const LatLng(12.9352, 77.6245),
    destination: const LatLng(12.9100, 77.6245),
    context: 'Medium, straight (~560m, S)',
  ),
  DemoRoute(
    id: '5',
    name: 'Coffee Shop',
    start: const LatLng(12.9352, 77.6245),
    destination: const LatLng(12.9450, 77.6100),
    context: 'Medium, mild bearing (~480m, NW)',
  ),
  DemoRoute(
    id: '6',
    name: 'Railway Station',
    start: const LatLng(12.9352, 77.6245),
    destination: const LatLng(12.9800, 77.6450),
    context: 'Medium-long, northeast (~720m, NE)',
  ),
  DemoRoute(
    id: '7',
    name: 'Market Street',
    start: const LatLng(12.9352, 77.6245),
    destination: const LatLng(12.9200, 77.6550),
    context: 'Medium, varied turns (~620m, SE)',
  ),
  DemoRoute(
    id: '8',
    name: 'Airport Access',
    start: const LatLng(12.9352, 77.6245),
    destination: const LatLng(12.7700, 77.5800),
    context: 'Long distance, urban highway (~2100m, SW)',
  ),
  DemoRoute(
    id: '9',
    name: 'Nearby Park',
    start: const LatLng(12.9352, 77.6245),
    destination: const LatLng(12.9320, 77.6180),
    context: 'Very short, westward (~220m, W)',
  ),
  DemoRoute(
    id: '10',
    name: 'Office Complex',
    start: const LatLng(12.9352, 77.6245),
    destination: const LatLng(12.9500, 77.5900),
    context: 'Long, complex path (~950m, NW)',
  ),
];
