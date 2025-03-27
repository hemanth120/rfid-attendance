import 'package:flutter/material.dart';
import 'student_addet.dart';

class AttendanceScreen extends StatefulWidget {
  final String studentid;

  AttendanceScreen({required this.studentid});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Future<void> navigateToAttendanceDetails() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceDetailsScreen(studentid: widget.studentid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Attendance Records',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
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
          child: GestureDetector(
            onTap: navigateToAttendanceDetails,
            child: futuristicButton(Icons.assignment_turned_in, "Get Attendance"),
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
