import 'dart:io'; // ADD THIS IMPORT
import 'package:flutter/material.dart';
import 'package:alzheimer_navigation_app/utils/constants.dart';
import 'package:alzheimer_navigation_app/models/person_model.dart';

class PersonDetailScreen extends StatelessWidget {
  final Person person;

  const PersonDetailScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Contact Details'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Large Photo
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppConstants.primaryColor,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 100,
                backgroundColor: _getRelationshipColor(person.relationship).withOpacity(0.1),
                backgroundImage: _getImageProvider(person),
                child: person.hasImage 
                    ? null
                    : Center(
                        child: Text(
                          person.name[0],
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Name
            Text(
              person.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Relationship Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getRelationshipColor(person.relationship),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                person.relationship,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Contact Information Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.phone,
                      title: 'Phone Number',
                      value: person.phoneNumber,
                    ),
                    const SizedBox(height: 16),
                    if (person.notes.isNotEmpty)
                      _buildDetailRow(
                        icon: Icons.note,
                        title: 'Notes',
                        value: person.notes,
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Call functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling ${person.name}...'),
                          backgroundColor: AppConstants.primaryColor,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.phone),
                    label: const Text(
                      'Call',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Message functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Messaging ${person.name}...'),
                          backgroundColor: AppConstants.secondaryColor,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.message),
                    label: const Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppConstants.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider? _getImageProvider(Person person) {
    if (person.imagePath != null) {
      return FileImage(File(person.imagePath!));
    } else if (person.imageUrl != null) {
      return NetworkImage(person.imageUrl!);
    }
    return null;
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
}