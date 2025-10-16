import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Alzheimer Care';
  static const String appTagline = 'Navigation & Safety App';
  
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color dangerColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  
  // OpenStreetMap Configuration
  static const String openStreetMapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String openStreetMapAttribution = 'OpenStreetMap Contributors';
  
  // Default locations
  static const double defaultLatitude = 12.9716;
  static const double defaultLongitude = 77.5946;
}