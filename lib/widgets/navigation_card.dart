import 'package:flutter/material.dart';
import 'package:alzheimer_navigation_app/utils/constants.dart';

class NavigationAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  NavigationAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class NavigationCard extends StatelessWidget {
  final String title;
  final List<NavigationAction> actions;

  const NavigationCard({
    super.key,
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: actions.map((action) {
                return Column(
                  children: [
                    IconButton(
                      onPressed: action.onTap,
                      icon: Icon(action.icon),
                      color: AppConstants.primaryColor,
                      iconSize: 30,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}