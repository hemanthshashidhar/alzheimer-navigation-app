import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const AlzheimerNavigationApp());
}

class AlzheimerNavigationApp extends StatelessWidget {
  const AlzheimerNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alzheimer Navigation & Safety',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}