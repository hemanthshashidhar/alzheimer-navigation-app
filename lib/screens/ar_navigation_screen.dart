import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:alzheimer_navigation_app/utils/constants.dart';
import 'package:alzheimer_navigation_app/data/demo_routes.dart';
import 'package:alzheimer_navigation_app/models/demo_route_model.dart';
import 'package:alzheimer_navigation_app/services/ar_service.dart';
import 'package:alzheimer_navigation_app/services/route_service.dart';
import 'package:alzheimer_navigation_app/screens/full_screen_map.dart';

class ARNavigationScreen extends StatefulWidget {
  const ARNavigationScreen({super.key});

  @override
  State<ARNavigationScreen> createState() => _ARNavigationScreenState();
}

class _ARNavigationScreenState extends State<ARNavigationScreen> {
  // AR Plugin managers
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  // Services
  final ARService _arService = ARService();
  final RouteService _routeService = RouteService();

  // Route selection
  DemoRoute? _selectedRoute;
  List<LatLng> _routePoints = [];
  List<String> _routeInstructions = [];

  // Location and orientation
  LatLng? _currentLocation;
  double _deviceHeading = 0.0; // Device compass heading (0-360)
  double _targetBearing = 0.0; // Bearing to destination
  double _distanceToDestination = 0.0;

  // Permissions and state
  bool _cameraPermissionGranted = false;
  bool _isInitializing = true;
  bool _isLoadingRoute = false;
  String? _errorMessage;

  // Streams
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  // Smoothing for heading (prevent jitter)
  final List<double> _headingBuffer = [];
  static const int _headingBufferSize = 5;

  @override
  void initState() {
    super.initState();
    _initializeAR();
  }

  Future<void> _initializeAR() async {
    // Request camera permission
    final cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      setState(() {
        _cameraPermissionGranted = true;
        _isInitializing = false;
      });
      _startLocationTracking();
      _startCompassTracking();
    } else {
      setState(() {
        _cameraPermissionGranted = false;
        _isInitializing = false;
        _errorMessage = 'Camera permission required for AR navigation';
      });
    }
  }

  void _startLocationTracking() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((Position position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);

        // Update distance if route is selected
        if (_selectedRoute != null) {
          _distanceToDestination = _arService.calculateDistance(
            _currentLocation!,
            _selectedRoute!.destination,
          );

          // Update target bearing
          _targetBearing = _arService.calculateBearing(
            _currentLocation!,
            _selectedRoute!.destination,
          );
        }
      });
    });
  }

  void _startCompassTracking() {
    _magnetometerSubscription = magnetometerEvents.listen((MagnetometerEvent event) {
      // Calculate heading from magnetometer data
      double heading = (event.x.atan2(event.y) * 180 / 3.14159265359 + 360) % 360;

      // Add to buffer for smoothing
      _headingBuffer.add(heading);
      if (_headingBuffer.length > _headingBufferSize) {
        _headingBuffer.removeAt(0);
      }

      // Calculate average heading
      double avgHeading = _headingBuffer.reduce((a, b) => a + b) / _headingBuffer.length;

      setState(() {
        _deviceHeading = avgHeading;
      });
    });
  }

  Future<void> _onRouteSelected(DemoRoute? route) async {
    if (route == null) return;

    setState(() {
      _selectedRoute = route;
      _isLoadingRoute = true;
      _errorMessage = null;
    });

    try {
      // Calculate route
      final routePoints = await _routeService.getRouteCoordinates(
        route.start,
        route.destination,
      );
      final instructions = await _routeService.getRouteInstructions(
        route.start,
        route.destination,
      );

      // Calculate initial bearing and distance
      final currentLoc = _currentLocation ?? route.start;
      final distance = _arService.calculateDistance(currentLoc, route.destination);
      final bearing = _arService.calculateBearing(currentLoc, route.destination);

      setState(() {
        _routePoints = routePoints;
        _routeInstructions = instructions;
        _distanceToDestination = distance;
        _targetBearing = bearing;
        _isLoadingRoute = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRoute = false;
        _errorMessage = 'Route calculation failed. Please try again.';
      });
    }
  }

  void _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;
  }

  void _openMapView() {
    if (_selectedRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a route first'),
          backgroundColor: AppConstants.warningColor,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMap(
          currentLocation: _currentLocation ?? _selectedRoute!.start,
          homeLocation: _selectedRoute!.destination,
          routePoints: _routePoints,
          distanceToHome: _distanceToDestination,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitializing
            ? _buildLoadingView()
            : !_cameraPermissionGranted
                ? _buildPermissionDeniedView()
                : _buildARView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppConstants.primaryColor),
          SizedBox(height: 16),
          Text(
            'Initializing AR...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: AppConstants.warningColor,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera permission required for AR navigation',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please grant camera access to use augmented reality features.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              icon: const Icon(Icons.map),
              label: const Text('Use Map Instead'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text(
                'Open Settings',
                style: TextStyle(color: AppConstants.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARView() {
    return Stack(
      children: [
        // AR Camera View
        ARView(
          onARViewCreated: _onARViewCreated,
        ),

        // Route Selector Dropdown (Top)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.white.withOpacity(0.95),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<DemoRoute>(
                  value: _selectedRoute,
                  decoration: const InputDecoration(
                    labelText: 'Select Test Route',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: demoRoutes.map((route) {
                    return DropdownMenuItem<DemoRoute>(
                      value: route,
                      child: Text(
                        route.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: _isLoadingRoute ? null : _onRouteSelected,
                ),
                if (_isLoadingRoute)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppConstants.dangerColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // AR Navigation Overlay
        if (_selectedRoute != null && !_isLoadingRoute)
          _buildNavigationOverlay(),

        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.7),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openMapView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.map, size: 20),
                    label: const Text('View Map'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationOverlay() {
    final relativeBearing = _arService.calculateRelativeBearing(
      _deviceHeading,
      _targetBearing,
    );

    return Stack(
      children: [
        // Turn Indicator (Top-left)
        Positioned(
          top: 80,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Turn',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _routeInstructions.isNotEmpty
                      ? _routeInstructions[0]
                      : 'Continue straight',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Distance Display (Top-right)
        Positioned(
          top: 80,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppConstants.secondaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Distance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _arService.formatDistanceDisplay(_distanceToDestination),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Direction Arrow (Center)
        Center(
          child: Transform.rotate(
            angle: relativeBearing * 3.14159265359 / 180,
            child: Icon(
              Icons.navigation,
              size: 120,
              color: AppConstants.primaryColor.withOpacity(0.9),
              shadows: const [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),

        // Compass Direction Label (Below Arrow)
        Positioned(
          bottom: 180,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _arService.getCardinalDirection(_targetBearing),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
