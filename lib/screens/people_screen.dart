import 'package:flutter/material.dart';
import 'package:alzheimer_navigation_app/utils/constants.dart';
import 'package:alzheimer_navigation_app/models/person_model.dart';
import 'person_detail_screen.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final List<Person> _people = [
    Person(
      id: '1',
      name: 'Virat Kohli',
      relationship: 'Friend',
      imageUrl: 'https://images.hindustantimes.com/img/2022/01/15/1600x900/kohli-aggressive-getty-test_1642272291768_1642272296847.jpg',
      phoneNumber: '+1 234 567 8901',
      notes: 'Cricket player, visits every weekend. Loves spending time with family.',
    ),
    Person(
      id: '2',
      name: 'Sarah Johnson',
      relationship: 'Daughter',
      imageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face',
      phoneNumber: '+1 234 567 8902',
      notes: 'Lives nearby, visits every weekend. Works as a teacher.',
    ),
    Person(
      id: '3',
      name: 'Dr. Michael Chen',
      relationship: 'Doctor',
      imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&h=400&fit=crop&crop=face',
      phoneNumber: '+1 234 567 8903',
      notes: 'Primary care physician. Specialist in elderly care.',
    ),
    Person(
      id: '4',
      name: 'Robert Wilson',
      relationship: 'Caregiver',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
      phoneNumber: '+1 234 567 8904',
      notes: 'Comes daily at 10 AM. Very helpful and patient.',
    ),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  void _addPerson() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Person I Know'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(color: AppConstants.primaryColor),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, color: AppConstants.primaryColor, size: 40),
                    SizedBox(height: 4),
                    Text(
                      'Photo',
                      style: TextStyle(fontSize: 12, color: AppConstants.primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && 
                  _relationshipController.text.isNotEmpty && 
                  _phoneController.text.isNotEmpty) {
                setState(() {
                  _people.insert(
                    0,
                    Person(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      relationship: _relationshipController.text,
                      phoneNumber: _phoneController.text,
                      notes: _notesController.text,
                      // For new people, we'll use a placeholder image
                      imageUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&h=400&fit=crop&crop=face',
                    ),
                  );
                });
                _nameController.clear();
                _relationshipController.clear();
                _phoneController.clear();
                _notesController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Person added successfully!'),
                    backgroundColor: AppConstants.secondaryColor,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _viewPersonDetails(Person person) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonDetailScreen(person: person),
      ),
    );
  }

  void _callPerson(Person person) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${person.name}...'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  void _deletePerson(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person'),
        content: const Text('Are you sure you want to delete this person?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _people.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Person deleted'),
                  backgroundColor: AppConstants.dangerColor,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
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

  Widget _buildPersonAvatar(Person person) {
    if (person.imageUrl != null) {
      return CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(person.imageUrl!),
        backgroundColor: _getRelationshipColor(person.relationship),
      );
    } else {
      return CircleAvatar(
        backgroundColor: _getRelationshipColor(person.relationship),
        radius: 25,
        child: Text(
          person.name[0],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People I Know'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _addPerson,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _people.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No people added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add someone you know',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _people.length,
              itemBuilder: (context, index) {
                final person = _people[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: _buildPersonAvatar(person),
                    title: Text(
                      person.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRelationshipColor(person.relationship).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            person.relationship,
                            style: TextStyle(
                              color: _getRelationshipColor(person.relationship),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          person.phoneNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _callPerson(person),
                          icon: const Icon(Icons.phone, color: AppConstants.primaryColor),
                          tooltip: 'Call',
                        ),
                        IconButton(
                          onPressed: () => _deletePerson(index),
                          icon: const Icon(Icons.delete, color: AppConstants.dangerColor),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                    onTap: () => _viewPersonDetails(person),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPerson,
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}