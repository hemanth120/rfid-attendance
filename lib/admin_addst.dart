import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final TextEditingController _rfidController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _error = '';

  Future<void> addStudent() async {
    try {
      final response = await http.post(
        Uri.parse('https://rfid-server-e7wi.onrender.com/admin/add-student'),
        body: json.encode({
          'rfiddata': _rfidController.text,
          'studentid': _studentIdController.text,
          'name': _nameController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Student added successfully')));
        _rfidController.clear();
        _studentIdController.clear();
        _nameController.clear();
      } else {
        setState(() {
          _error = 'Error adding student';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error adding student';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Admin Panel',
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
                Icon(Icons.supervised_user_circle, size: 80, color: Colors.cyanAccent),
                SizedBox(height: 20),
                Text(
                  'Add Student',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 40),

                // RFID Data Input
                futuristicTextField(_rfidController, 'RFID Data'),

                SizedBox(height: 20),

                // Student ID Input
                futuristicTextField(_studentIdController, 'Student ID'),

                SizedBox(height: 20),

                // Name Input
                futuristicTextField(_nameController, 'Name'),

                SizedBox(height: 20),

                // Add Student Button
                GestureDetector(
                  onTap: addStudent,
                  child: futuristicButton(Icons.person_add, "Add Student"),
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
  Widget futuristicTextField(TextEditingController controller, String label) {
    return SizedBox(
      width: 400,
      child: TextField(
        controller: controller,
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
