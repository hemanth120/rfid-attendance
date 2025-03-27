import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'adminpage.dart';
import 'student_getad.dart';

extension StringCapitalization on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}

class LoginScreen extends StatefulWidget {
  final String userType;

  LoginScreen({required this.userType});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _error = '';

  // Login function
  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse('https://rfid-server-e7wi.onrender.com/login'),
        body: json.encode({
          'studentid': _studentIdController.text,
          'password': _passwordController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String studentid = data['studentid'];

        if (widget.userType == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AttendanceScreen(studentid: studentid)),
          );
        }
      } else {
        setState(() {
          _error = 'Invalid student ID or password';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Login failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Student Login',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.cyanAccent,
        elevation: 8,
        shadowColor: Colors.cyanAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_circle, size: 80, color: Colors.cyanAccent),
                  SizedBox(height: 20),
                  Text(
                    'Student Access',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 40),

                  // Student ID Field
                  futuristicTextField(_studentIdController, 'Student ID', false),

                  SizedBox(height: 20),

                  // Password Field
                  futuristicTextField(_passwordController, 'Password', true),

                  SizedBox(height: 20),

                  // Login Button
                  GestureDetector(
                    onTap: login,
                    child: futuristicButton(Icons.login, "Login"),
                  ),

                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _error,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Futuristic TextField
  Widget futuristicTextField(TextEditingController controller, String label, bool obscure) {
    return SizedBox(
      width: 400,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.cyanAccent),
          filled: true,
          fillColor: Colors.black.withOpacity(0.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyanAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyanAccent, width: 2),
          ),
        ),
      ),
    );
  }

  // Futuristic Button
  Widget futuristicButton(IconData icon, String text) {
    return Container(
      width: 250,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyanAccent, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 3),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 26),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
          ),
        ],
      ),
    );
  }
}
