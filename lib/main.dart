import 'package:flutter/material.dart';
import 'home.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
