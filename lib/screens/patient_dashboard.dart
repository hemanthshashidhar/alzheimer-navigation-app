import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:alzheimer_navigation_app/utils/constants.dart';
import 'package:alzheimer_navigation_app/widgets/sos_button.dart';
import 'package:alzheimer_navigation_app/models/reminder_model.dart';
import 'package:alzheimer_navigation_app/services/route_service.dart';
import 'profile_screen.dart';
import 'reminders_screen.dart';
import 'full_screen_map.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final MapController _mapController = MapController();
  final RouteService _routeService = RouteService();
  final LatLng _homeLocation = const LatLng(12.9716, 77.5946); // Fixed home in Bangalore
  LatLng _currentLocation = const LatLng(12.9352, 77.6245); // Current location (different from home)
  double _distanceToHome = 850.0; // meters
  List<LatLng> _routePoints = [];
  List<String> _routeInstructions = [];
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _initializeRoute();
  }

  void _initializeRoute() async {
    setState(() {
      _isLoadingRoute = true;
    });
    
    // Calculate realistic route distance
    final double routeDistance = await _routeService.calculateRouteDistance(_currentLocation, _homeLocation);
    
    // Get realistic route coordinates
    final List<LatLng> routePoints = await _routeService.getRouteCoordinates(_currentLocation, _homeLocation);
    
    // Get route instructions
    final List<String> instructions = await _routeService.getRouteInstructions(_currentLocation, _homeLocation);
    
    setState(() {
      _distanceToHome = routeDistance;
      _routePoints = routePoints;
      _routeInstructions = instructions;
      _isLoadingRoute = false;
    });
  }

  void _onSOSPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppConstants.dangerColor),
            SizedBox(width: 8),
            Text('Emergency Alert'),
          ],
        ),
        content: const Text(
          'SOS signal has been sent to your emergency contacts and caregivers. Help is on the way! Stay calm and stay where you are.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateHome() {
    if (_routePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calculating route...'),
          backgroundColor: AppConstants.warningColor,
        ),
      );
      return;
    }

    // Center map on the route
    final LatLngBounds routeBounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.fitBounds(
      routeBounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
    );
    
    // Show directions information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.directions, color: AppConstants.primaryColor),
            SizedBox(width: 8),
            Text('Directions to Home'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distance: ${(_distanceToHome / 1000).toStringAsFixed(1)} km',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Estimated time: 10-15 minutes walk'),
              const SizedBox(height: 12),
              const Text(
                'Route Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._routeInstructions.take(3).map((instruction) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.navigate_next, size: 16, color: AppConstants.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(child: Text(instruction)),
                  ],
                ),
              )),
              if (_routeInstructions.length > 3)
                Text(
                  '... and ${_routeInstructions.length - 3} more steps',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Follow the blue route line on the map',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RemindersScreen()),
    );
  }

  void _callCaregiver() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling caregiver...'),
        backgroundColor: AppConstants.secondaryColor,
      ),
    );
  }

  void _openFullScreenMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMap(
          currentLocation: _currentLocation,
          homeLocation: _homeLocation,
          routePoints: _routePoints,
          distanceToHome: _distanceToHome,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Alzheimer Care - Patient',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.primaryColor.withOpacity(0.8),
                  AppConstants.primaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Patient User!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You are safe and being monitored',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _isLoadingRoute 
                          ? 'Calculating route...'
                          : 'Distance to home: ${(_distanceToHome / 1000).toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Location Tracking Status
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _isLoadingRoute ? AppConstants.warningColor : AppConstants.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isLoadingRoute ? 'Calculating Route...' : 'Location Tracking Active',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  _isLoadingRoute ? Icons.sync : Icons.check_circle,
                  color: _isLoadingRoute ? AppConstants.warningColor : AppConstants.secondaryColor,
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Map Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.map, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Map View',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (_isLoadingRoute)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: _openFullScreenMap,
                    icon: const Icon(Icons.fullscreen, color: AppConstants.primaryColor),
                    tooltip: 'Full Screen Map',
                  ),
                Text(
                  'OpenStreetMap',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Map Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentLocation,
                    zoom: 14.0,
                    interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: AppConstants.openStreetMapUrl,
                      userAgentPackageName: 'com.example.alzheimer_navigation_app',
                    ),
                    // Draw realistic route line
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: AppConstants.primaryColor.withOpacity(0.8),
                            strokeWidth: 6,
                            borderStrokeWidth: 2,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // Home Marker
                        Marker(
                          point: _homeLocation,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppConstants.secondaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.home,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        // Current Location Marker
                        Marker(
                          point: _currentLocation,
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingRoute ? null : _navigateHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoadingRoute ? Colors.grey : AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.directions, size: 20),
                    label: Text(
                      _isLoadingRoute ? 'Calculating...' : 'Navigate Home',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onSOSPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.dangerColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.warning, size: 20),
                    label: const Text(
                      'SOS Emergency',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Actions Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.notifications,
                        label: 'View Reminders',
                        onTap: _viewReminders,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.phone,
                        label: 'Call Caregiver',
                        onTap: _callCaregiver,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppConstants.primaryColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}