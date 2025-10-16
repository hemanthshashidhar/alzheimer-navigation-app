import 'package:flutter/material.dart';
import 'package:alzheimer_navigation_app/utils/constants.dart';
import 'package:alzheimer_navigation_app/widgets/location_card.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  final List<Map<String, dynamic>> _patients = [
    {
      'name': 'John Doe',
      'status': 'Safe',
      'lastSeen': '2 minutes ago',
      'battery': 85,
    },
    {
      'name': 'Mary Smith',
      'status': 'Moving',
      'lastSeen': '5 minutes ago',
      'battery': 45,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with stats
          Container(
            padding: const EdgeInsets.all(16),
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Patients', '2', Icons.group),
                _buildStat('Alerts', '0', Icons.warning),
                _buildStat('Active', '2', Icons.location_on),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                return LocationCard(
                  patientName: patient['name'],
                  status: patient['status'],
                  lastSeen: patient['lastSeen'],
                  batteryLevel: patient['battery'],
                  onTap: () {
                    _showPatientDetails(patient);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new patient
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppConstants.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showPatientDetails(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Status', patient['status']),
              _buildDetailRow('Last Seen', patient['lastSeen']),
              _buildDetailRow('Battery', '${patient['battery']}%'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Show location on map (will implement later)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Showing patient location...')),
                    );
                  },
                  child: const Text('View Location'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:'),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}