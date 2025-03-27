import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCredentialsScreen extends StatefulWidget {
  @override
  _AddCredentialsScreenState createState() => _AddCredentialsScreenState();
}

class _AddCredentialsScreenState extends State<AddCredentialsScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _error = '';
  bool _isLoading = false;

  // Function to make POST request to add credentials
  Future<void> addCredentials() async {
    if (_studentIdController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _error = 'All fields are required!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://rfid-server-e7wi.onrender.com/admin/add-credentials'),
        body: json.encode({
          'studentid': _studentIdController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Credentials added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _studentIdController.clear();
        _passwordController.clear();
      } else {
        setState(() {
          _error = '❌ Error adding credentials';
        });
      }
    } catch (e) {
      setState(() {
        _error = '❌ Connection Error: Unable to add credentials';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extends body behind AppBar
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add Credentials',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.cyanAccent,
        elevation: 8,
        shadowColor: Colors.cyanAccent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  futuristicTextField(_studentIdController, "Student ID", false, Icons.person),
                  SizedBox(height: 20),
                  futuristicTextField(_passwordController, "Password", true, Icons.lock),
                  SizedBox(height: 20),

                  _isLoading
                      ? CircularProgressIndicator(color: Colors.cyanAccent)
                      : futuristicButton(Icons.add, "Add Credentials", addCredentials),

                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        _error,
                        style: TextStyle(fontSize: 14, color: Colors.redAccent),
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
  Widget futuristicTextField(TextEditingController controller, String label, bool obscure, IconData icon) {
    return SizedBox(
      width: 400,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.cyanAccent),
          labelText: label,
          labelStyle: TextStyle(color: Colors.cyanAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent, width: 2)),
        ),
      ),
    );
  }

  // Futuristic Button
  Widget futuristicButton(IconData icon, String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 220,
        height: 50,
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
            Icon(icon, color: Colors.cyanAccent, size: 24),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
            ),
          ],
        ),
      ),
    );
  }
}
