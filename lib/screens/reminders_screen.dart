import 'package:flutter/material.dart';
import 'package:alzheimer_navigation_app/utils/constants.dart';
import 'package:alzheimer_navigation_app/models/reminder_model.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<Reminder> _reminders = [
    Reminder(
      id: '1',
      title: 'Take Morning Medicine',
      description: 'Take blood pressure medication after breakfast',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Reminder(
      id: '2',
      title: 'Doctor Appointment',
      description: 'Visit Dr. Smith at 3:00 PM today',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Reminder(
      id: '3',
      title: 'Family Dinner',
      description: 'Dinner with family at 7:00 PM',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _addReminder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                setState(() {
                  _reminders.insert(
                    0,
                    Reminder(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      description: _descriptionController.text,
                      createdAt: DateTime.now(),
                    ),
                  );
                });
                _titleController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder added successfully!'),
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

  void _toggleReminderCompletion(int index) {
    setState(() {
      _reminders[index] = _reminders[index].copyWith(
        isCompleted: !_reminders[index].isCompleted,
      );
    });
  }

  void _deleteReminder(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _reminders.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reminder deleted'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _addReminder,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _reminders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No reminders yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a reminder',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Checkbox(
                      value: reminder.isCompleted,
                      onChanged: (value) => _toggleReminderCompletion(index),
                      activeColor: AppConstants.primaryColor,
                    ),
                    title: Text(
                      reminder.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: reminder.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: reminder.isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reminder.description.isNotEmpty)
                          Text(
                            reminder.description,
                            style: TextStyle(
                              decoration: reminder.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color:
                                  reminder.isCompleted ? Colors.grey : Colors.black54,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Added: ${_formatDate(reminder.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () => _deleteReminder(index),
                      icon: const Icon(Icons.delete, color: AppConstants.dangerColor),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}