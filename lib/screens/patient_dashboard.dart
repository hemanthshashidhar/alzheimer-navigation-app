import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:alzheimer_navigation_app/utils/constants.dart';
import 'package:alzheimer_navigation_app/widgets/sos_button.dart';
import 'package:alzheimer_navigation_app/models/reminder_model.dart';
import 'package:alzheimer_navigation_app/models/person_model.dart';
import 'package:alzheimer_navigation_app/services/route_service.dart';
import 'profile_screen.dart';
import 'reminders_screen.dart';
import 'full_screen_map.dart';
import 'people_screen.dart';
import 'ar_navigation_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final MapController _mapController = MapController();
  final RouteService _routeService = RouteService();
  final LatLng _homeLocation = const LatLng(12.9716, 77.5946);
  LatLng _currentLocation = const LatLng(12.9352, 77.6245);
  double _distanceToHome = 850.0;
  List<LatLng> _routePoints = [];
  List<String> _routeInstructions = [];
  bool _isLoadingRoute = false;

  // Sample people data
  final List<Person> _people = [
    Person(
      id: '1',
      name: 'Virat Kohli',
      relationship: 'Son',
      imageUrl: 'https://www.bing.com/th?id=OIP.8RwYQY9y9y9y9y9y9y9y9wHaE8&pid=Api',
      phoneNumber: '+1 234 567 8901',
      notes: 'Cricket player, visits every weekend',
    ),
    Person(
      id: '2',
      name: 'Sarah Johnson',
      relationship: 'Daughter',
      imageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
      phoneNumber: '+1 234 567 8901',
      notes: 'Lives nearby, visits every weekend',
    ),
    Person(
      id: '3',
      name: 'Dr. Michael Chen',
      relationship: 'Doctor',
      imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=150&h=150&fit=crop&crop=face',
      phoneNumber: '+1 234 567 8902',
      notes: 'Primary care physician',
    ),
    Person(
      id: '4',
      name: 'Robert Wilson',
      relationship: 'Caregiver',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      phoneNumber: '+1 234 567 8903',
      notes: 'Comes daily at 10 AM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeRoute();
  }

  void _initializeRoute() async {
    setState(() {
      _isLoadingRoute = true;
    });
    
    final double routeDistance = await _routeService.calculateRouteDistance(_currentLocation, _homeLocation);
    final List<LatLng> routePoints = await _routeService.getRouteCoordinates(_currentLocation, _homeLocation);
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

    final LatLngBounds routeBounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.fitBounds(
      routeBounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
    );
    
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

  void _openARNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ARNavigationScreen(),
      ),
    );
  }

  Color _getRelationshipColor(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'daughter':
      case 'son':
      case 'family':
        return AppConstants.primaryColor;
      case 'doctor':
        return AppConstants.secondaryColor;
      case 'caregiver':
        return AppConstants.warningColor;
      default:
        return Colors.grey;
    }
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
      body: SingleChildScrollView(
        child: Column(
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
            Container(
              height: 250,
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

            const SizedBox(height: 20),

            // People I Know Section
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
                  const Row(
                    children: [
                      Icon(Icons.people, color: AppConstants.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'People I Know',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._people.take(2).map((person) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: person.imageUrl != null && person.imageUrl!.isNotEmpty
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(person.imageUrl!),
                              backgroundColor: _getRelationshipColor(person.relationship),
                            )
                          : CircleAvatar(
                              backgroundColor: _getRelationshipColor(person.relationship),
                              radius: 20,
                              child: Text(
                                person.name[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      title: Text(
                        person.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        person.relationship,
                        style: TextStyle(
                          color: _getRelationshipColor(person.relationship),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${person.name}...'),
                              backgroundColor: AppConstants.primaryColor,
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone, color: AppConstants.primaryColor),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${person.name} - ${person.relationship}'),
                            backgroundColor: AppConstants.primaryColor,
                          ),
                        );
                      },
                    ),
                  )),
                  if (_people.length > 2)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PeopleScreen()),
                        );
                      },
                      child: Text(
                        'View all ${_people.length} people',
                        style: const TextStyle(color: AppConstants.primaryColor),
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