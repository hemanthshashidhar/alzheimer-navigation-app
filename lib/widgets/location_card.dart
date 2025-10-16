import 'package:flutter/material.dart';
import 'package:alzheimer_navigation_app/utils/constants.dart';

class LocationCard extends StatelessWidget {
  final String patientName;
  final String status;
  final String lastSeen;
  final int batteryLevel;
  final VoidCallback onTap;

  const LocationCard({
    super.key,
    required this.patientName,
    required this.status,
    required this.lastSeen,
    required this.batteryLevel,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'safe':
        return AppConstants.secondaryColor;
      case 'moving':
        return AppConstants.warningColor;
      case 'alert':
        return AppConstants.dangerColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor,
          child: Text(
            patientName[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(patientName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last seen: $lastSeen'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.battery_std,
                  color: batteryLevel < 20 ? AppConstants.dangerColor : Colors.green,
                  size: 16,
                ),
                Text(' $batteryLevel%'),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}