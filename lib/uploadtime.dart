import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as Foundation;

class UploadTimetableScreen extends StatefulWidget {
  @override
  _UploadTimetableScreenState createState() => _UploadTimetableScreenState();
}

class _UploadTimetableScreenState extends State<UploadTimetableScreen> {
  String? fileName;
  bool _isUploading = false;

  Future<void> uploadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
        _isUploading = true;
      });

      Uint8List fileBytes;
      if (Foundation.kIsWeb) {
        fileBytes = result.files.single.bytes!;
      } else {
        File file = File(result.files.single.path!);
        fileBytes = file.readAsBytesSync();
      }

      await _uploadFile(fileBytes, result.files.single.name);
    } else {
      showSnackBar("No file selected", Colors.redAccent);
    }
  }

  Future<void> _uploadFile(Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://rfid-server-e7wi.onrender.com/upload-timetable'),
      );

      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      );
      request.files.add(multipartFile);

      var response = await request.send();

      if (response.statusCode == 200) {
        showSnackBar("✅ Timetable uploaded successfully", Colors.green);
      } else {
        showSnackBar("❌ Failed to upload timetable", Colors.redAccent);
      }
    } catch (e) {
      showSnackBar("❌ Error uploading file", Colors.redAccent);
    }

    setState(() {
      _isUploading = false;
    });
  }

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Upload Timetable',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (fileName != null)
                  Text(
                    '📄 Selected File: $fileName',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                SizedBox(height: 20),

                _isUploading
                    ? CircularProgressIndicator(color: Colors.cyanAccent)
                    : futuristicButton(Icons.upload_file, "Upload Timetable", uploadExcelFile),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
