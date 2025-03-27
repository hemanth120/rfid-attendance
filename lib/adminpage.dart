import 'package:flutter/material.dart';
import 'admin_addst.dart';
import 'admin_stcred.dart';
import 'admin_viewad.dart';
import 'uploadtime.dart';

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Admin Dashboard',
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                futuristicButton(Icons.person_add, "Add Student", context, AdminPanel()),
                SizedBox(height: 20),
                futuristicButton(Icons.visibility, "View Attendance", context, ViewAttendanceScreen()),
                SizedBox(height: 20),
                futuristicButton(Icons.key, "Add Credentials", context, AddCredentialsScreen()),
                SizedBox(height: 20),
                futuristicButton(Icons.upload_file, "Update Timetable", context, UploadTimetableScreen()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Futuristic Button UI (Same as Home Page)
  Widget futuristicButton(IconData icon, String text, BuildContext context, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Container(
        width: 300,
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
      ),
    );
  }
}
