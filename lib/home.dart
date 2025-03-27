import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'adminlogin.dart';
import 'studentlogin.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Smart Attendance System',
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // iPhone Face ID Symbol using Cupertino Icons
              Icon(CupertinoIcons.person_crop_circle_badge_checkmark, size: 80, color: Colors.cyanAccent),
              SizedBox(height: 20),
              Text(
                'Welcome',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              SizedBox(height: 40),

              // User Login Button
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(userType: 'user')));
                },
                child: futuristicButton(Icons.person, "Student Login"),
              ),
              SizedBox(height: 20),

              // Admin Login Button
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminLoginScreen()));
                },
                child: futuristicButton(Icons.admin_panel_settings, "Admin Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Futuristic Button
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
