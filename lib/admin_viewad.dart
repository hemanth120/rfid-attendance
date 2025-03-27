import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewAttendanceScreen extends StatefulWidget {
  @override
  _ViewAttendanceScreenState createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  List<dynamic> attendanceData = [];
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;

  Future<void> fetchAttendance() async {
    try {
      final response = await http.get(
        Uri.parse('https://rfid-server-e7wi.onrender.com/admin/attendance-summary'),
      );

      if (response.statusCode == 200) {
        setState(() {
          attendanceData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch attendance data')));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch attendance data')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extends body behind the app bar
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Attendance Summary',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.cyanAccent,
        elevation: 8,
        shadowColor: Colors.cyanAccent,
      ),
      body: Container(
        width: double.infinity, // Makes sure the background covers full width
        height: double.infinity, // Makes sure the background covers full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + 20), // Adds space below the AppBar

            // Refresh Button
            GestureDetector(
              onTap: fetchAttendance,
              child: futuristicButton(Icons.refresh, "Refresh Data"),
            ),

            SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                  : attendanceData.isEmpty
                      ? Center(
                          child: Text(
                            "No Attendance Data Available",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        )
                      : SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              columnSpacing: 15,
                              dataRowHeight: 50,
                              headingRowColor:
                                  MaterialStateColor.resolveWith((states) => Colors.black87),
                              border: TableBorder.all(color: Colors.cyanAccent),
                              columns: [
                                futuristicDataColumn('Student ID'),
                                futuristicDataColumn('Subject'),
                                futuristicDataColumn('Total Classes'),
                                futuristicDataColumn('Present'),
                                futuristicDataColumn('Absent'),
                                futuristicDataColumn('Percentage'),
                              ],
                              rows: attendanceData.map((attendance) {
                                return DataRow(cells: [
                                  futuristicDataCell(attendance['studentid']),
                                  futuristicDataCell(attendance['subject']),
                                  futuristicDataCell(attendance['classes_conducted']),
                                  futuristicDataCell(attendance['classes_present']),
                                  futuristicDataCell(attendance['classes_absent']),
                                  futuristicDataCell(attendance['percentage']),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Futuristic Data Column
  DataColumn futuristicDataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
      ),
    );
  }

  // Futuristic Data Cell
  DataCell futuristicDataCell(dynamic value) {
    return DataCell(
      Text(
        value.toString(),
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }

  // Futuristic Button
  Widget futuristicButton(IconData icon, String text) {
    return Container(
      width: 200,
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
    );
  }
}
