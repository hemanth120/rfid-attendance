import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubjectDetailsScreen extends StatefulWidget {
  final String studentid;
  final String subject;

  SubjectDetailsScreen({required this.studentid, required this.subject});

  @override
  _SubjectDetailsScreenState createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  List<Map<String, String>> _subjectDetails = [];
  String _error = '';

  Future<void> fetchSubjectDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://rfid-server-e7wi.onrender.com/attendance/subject/${widget.subject}?rfid_id=${widget.studentid}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _subjectDetails = jsonData.map((item) {
            if (item is Map<String, dynamic>) {
              return Map<String, String>.from(item);
            } else {
              throw FormatException('Unexpected JSON format');
            }
          }).toList();
          _error = '';
        });
      } else {
        setState(() {
          _error = 'Error fetching subject details: ${response.statusCode} ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching subject details: ${e.toString()}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSubjectDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${widget.subject} Details',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
            padding: const EdgeInsets.all(16.0),
            child: _error.isNotEmpty
                ? Center(
                    child: Text(
                      _error,
                      style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : _subjectDetails.isEmpty
                    ? Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                    : Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.cyanAccent, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 3),
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Colors.blueGrey[900]),
                            dataRowColor: MaterialStateProperty.all(Colors.grey[850]),
                            columnSpacing: 20,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Date',
                                  style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Time',
                                  style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status',
                                  style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: _subjectDetails.map((detail) {
                              return DataRow(cells: [
                                futuristicDataCell(detail['date'] ?? ''),
                                futuristicDataCell(detail['time'] ?? ''),
                                futuristicStatusCell(detail['status'] ?? ''),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  // Futuristic styled DataCell
  DataCell futuristicDataCell(String text) {
    return DataCell(
      Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Futuristic Status Cell with neon color coding
  DataCell futuristicStatusCell(String status) {
    return DataCell(
      Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: status == 'Present' ? Colors.greenAccent.withOpacity(0.8) : Colors.redAccent.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: status == 'Present' ? Colors.greenAccent.withOpacity(0.5) : Colors.redAccent.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            status,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
