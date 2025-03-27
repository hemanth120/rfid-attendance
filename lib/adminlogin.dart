import 'dart:convert';
import 'package:flutter/material.dart';
import 'adminpage.dart';
import 'package:http/http.dart' as http;

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _adminIdController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
  String _error = '';

  Future<void> adminLogin() async {
    try {
      final response = await http.post(
        Uri.parse('https://rfid-server-e7wi.onrender.com/admin/login'),
        body: json.encode({
          'adminid': _adminIdController.text,
          'password': _adminPasswordController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );
      } else {
        setState(() {
          _error = 'Invalid admin ID or password';
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
          'Admin Login',
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings, size: 80, color: Colors.cyanAccent),
                SizedBox(height: 20),
                Text(
                  'Admin Access',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 40),

                // Admin ID Field
                futuristicTextField(_adminIdController, 'Admin ID', false),

                SizedBox(height: 20),

                // Password Field
                futuristicTextField(_adminPasswordController, 'Password', true),

                SizedBox(height: 20),

                // Login Button
                GestureDetector(
                  onTap: adminLogin,
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
