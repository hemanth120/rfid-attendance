import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'student_subad.dart';

class AttendanceDetailsScreen extends StatefulWidget {
  final String studentid;

  AttendanceDetailsScreen({required this.studentid});

  @override
  _AttendanceDetailsScreenState createState() => _AttendanceDetailsScreenState();
}

class _AttendanceDetailsScreenState extends State<AttendanceDetailsScreen> {
  List<dynamic> _attendanceRecords = [];
  String _error = '';

  Future<void> fetchAttendance() async {
    try {
      final response = await http.get(
        Uri.parse('https://rfid-server-e7wi.onrender.com/attendance?rfid_id=${widget.studentid}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _attendanceRecords = json.decode(response.body);
          _error = '';
        });
      } else {
        setState(() {
          _error = 'Error fetching attendance';
          _attendanceRecords = [];
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching attendance';
        _attendanceRecords = [];
      });
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Attendance Details',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                )
              : _attendanceRecords.isEmpty
                  ? Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                  : Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.cyanAccent, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 3),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade800),
                            border: TableBorder(
                              horizontalInside: BorderSide(color: Colors.cyanAccent.withOpacity(0.5), width: 1),
                            ),
                            columns: _buildColumns(),
                            rows: _attendanceRecords.map((record) => _buildRow(record)).toList(),
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      _styledColumn('Subject'),
      _styledColumn('Classes Conducted'),
      _styledColumn('Classes Present'),
      _styledColumn('Classes Absent'),
      _styledColumn('Percentage'),
      _styledColumn('Details'),
    ];
  }

  DataColumn _styledColumn(String title) {
    return DataColumn(
      label: Center(
        child: Text(
          title,
          style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataRow _buildRow(dynamic record) {
    return DataRow(
      cells: [
        _styledCell(record['subject']),
        _styledCell(record['classes_conducted'].toString()),
        _styledCell(record['classes_present'].toString()),
        _styledCell(record['classes_absent'].toString()),
        _styledCell(record['percentage'].toString()),
        DataCell(Center(child: _detailsButton(record['subject']))),
      ],
    );
  }

  DataCell _styledCell(String value) {
    return DataCell(
      Center(
        child: Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _detailsButton(String subject) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailsScreen(subject: subject, studentid: widget.studentid),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.cyanAccent, width: 1.5),
          color: Colors.black.withOpacity(0.6),
          boxShadow: [
            BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 3),
          ],
        ),
        child: Text(
          'Details',
          style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
