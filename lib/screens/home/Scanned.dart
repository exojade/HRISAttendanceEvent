import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diary_app/repository/notes_repository.dart';
import '../../layouts/bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannedLogsScreen extends StatefulWidget {
  const ScannedLogsScreen({Key? key}) : super(key: key);

  @override
  State<ScannedLogsScreen> createState() => _ScannedLogsScreenState();
}

class _ScannedLogsScreenState extends State<ScannedLogsScreen> {
  List<Map<String, dynamic>> scanLogs = [];

  @override
  void initState() {
    super.initState();
    fetchScanLogs();
  }

  Future<void> fetchScanLogs() async {
    try {
      List<Map<String, dynamic>> logs = await NoteRepository.getAllScanLogs();
      setState(() {
        scanLogs = logs;
      });
    } catch (e) {
      print('Error fetching scan logs: $e');
    }
  }

  void _uploadScanLogs() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing dialog on outside tap
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(), // Show loading indicator
        );
      },
    );

    try {
      // Convert scanLogs data to JSON format
      List<Map<String, dynamic>> logs = scanLogs;
      String jsonData = jsonEncode(logs);
      print(jsonData);

      // Make POST request to the API endpoint
      final response = await http.post(
        Uri.parse('http://203.177.88.234:7000/hris/insertLogs'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Close the loading dialog
      Navigator.pop(context);

      // Check the response status
      if (response.statusCode == 200) {
        print('Logs uploaded successfully');
        // Clear scanLogs after successful upload
        setState(() {
          scanLogs = [];
        });

        // Delete scan_logs data from SQLite
        await NoteRepository.deleteScanLogs();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'Failed to upload logs. Status code: ${response.statusCode}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Close the loading dialog
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to upload logs. Status code: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      print('Error uploading logs: $e');
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _logout();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    await NoteRepository.deleteUsers();
    Navigator.pushReplacementNamed(context, '/');
  }

  String convertTo12HourFormat(String time24Hour) {
    // Parse the input time string
    List<String> parts = time24Hour.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    // Create a DateTime object with today's date and the given time
    DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, hour, minute);

    // Format the DateTime object in 12-hour format
    return DateFormat.jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Scanned Logs'),
            IconButton(
              onPressed: _uploadScanLogs, // Call _uploadScanLogs when pressed
              icon: Icon(Icons.cloud_upload),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: scanLogs.length,
        itemBuilder: (context, index) {
          final log = scanLogs[index];
          return Card(
            child: ListTile(
              title: Text(
                  log['fullname'] + "(" + log["Department"] + ")" ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event: ${log['event_name'] ?? 'Unknown'}'),
                  Text(
                      'Date: ${log['date'] + " " + convertTo12HourFormat(log["time"]) ?? 'Unknown'}'),
                  Text('Remarks: ${log['remarks'] ?? 'Unknown'}'),
                  Text('Scanned By: ${log['scanner_fullname'] ?? 'Unknown'}'),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/employees');
          } else if (index == 3) {
            _showLogoutConfirmation(context);
          }
        },
      ),
    );
  }
}
