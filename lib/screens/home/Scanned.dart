import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diary_app/repository/notes_repository.dart';
import 'package:diary_app/screens/home/ScannedLogsHistoryPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../layouts/bottom_nav_bar.dart';
import 'package:diary_app/models/users.dart';
import 'package:diary_app/models/serverUrl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannedLogsScreen extends StatefulWidget {
  const ScannedLogsScreen({Key? key}) : super(key: key);

  @override
  State<ScannedLogsScreen> createState() => _ScannedLogsScreenState();
}

class _ScannedLogsScreenState extends State<ScannedLogsScreen> {
  List<Map<String, dynamic>> scanLogs = [];
  int _scanCount = 0;
  bool _isDownloading = false;

  String? _userId;
  String? _serverUrl = "";

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchScanLogs();
    fetchEmployeeCount();
    fetchUrl();
  }

  Future<void> fetchUserId() async {
    try {
      List<User> users = await NoteRepository.getUsers();
      if (users.isNotEmpty) {
        setState(() {
          _userId = users.first.userId;
        });
      }
    } catch (e) {
      // print('Error fetching user id: $e');
    }
  }

  Future<void> fetchUrl() async {
    try {
      List<ServerUrl> serverUrl = await NoteRepository.getServerUrl();
      if (serverUrl.isNotEmpty) {
        setState(() {
          _serverUrl = serverUrl.first.serverUrl;
        });
      }
    } catch (e) {
      // print('Error fetching user id: $e');
    }
  }

  Future<void> fetchEmployeeCount() async {
    int count = await NoteRepository.getScanLogsCount();
    setState(() {
      _scanCount = count;
    });
  }

  Future<void> fetchScanLogs() async {
    try {
      List<Map<String, dynamic>> logs = await NoteRepository.getAllScanLogs();
      setState(() {
        scanLogs = logs;
      });
    } catch (e) {
      // print('Error fetching scan logs: $e');
    }
  }

  void _uploadScanLogs() async {
    // showDialog(
    //   context: context,
    //   barrierDismissible: false, // Prevent closing dialog on outside tap
    //   builder: (BuildContext context) {
    //     return Center(
    //       child: CircularProgressIndicator(), // Show loading indicator
    //     );
    //   },
    // );

    try {
      setState(() {
        _isDownloading = true; // Set downloading flag to true
      });

      // Convert scanLogs data to JSON format
      List<Map<String, dynamic>> logs = scanLogs;
      String jsonData = jsonEncode(logs);
      // print(jsonData);

      // Make POST request to the API endpoint
      String theUrl = _serverUrl.toString() + '/hris/insertLogs';
      final response = await http.post(
        Uri.parse(theUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Close the loading dialog
      // Navigator.pop(context);

      // Check the response status

      setState(() {
        _isDownloading = false; // Set downloading flag to true
      });

      if (response.statusCode == 200) {
        // print('Logs uploaded successfully');
        // Clear scanLogs after successful upload
        setState(() {
          scanLogs = [];
        });

        // Delete scan_logs data from SQLite
        await NoteRepository.archiveScanLogs();
        Fluttertoast.showToast(
          msg: 'DONE UPLOAD',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: '${response.statusCode}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        setState(() {
          _isDownloading = false; // Set downloading flag to true
        });
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: Text('Error'),
        //       content: Text(
        //           'Failed to upload logs. Status code: ${response.statusCode}'),
        //       actions: [
        //         TextButton(
        //           onPressed: () {
        //             Navigator.pop(context); // Close the dialog
        //           },
        //           child: Text('OK'),
        //         ),
        //       ],
        //     );
        //   },
        // );
      }
    } catch (e) {
      // Close the loading dialog
      // Navigator.pop(context);

      Fluttertoast.showToast(
        msg: 'Failed to upload logs. Status code: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text('Error'),
      //       content: Text('Failed to upload logs. Status code: $e'),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.pop(context); // Close the dialog
      //           },
      //           child: Text('OK'),
      //         ),
      //       ],
      //     );
      //   },
      // );
      // print('Error uploading logs: $e');
    }

    fetchEmployeeCount();
  }

  // void _showLogoutConfirmation(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Confirm Logout'),
  //         content: Text('Are you sure you want to logout?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context); // Close the dialog
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context); // Close the dialog
  //               // _logout();
  //             },
  //             child: Text('Logout'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _logout() async {
  //   await NoteRepository.deleteUsers();
  //   Navigator.pushReplacementNamed(context, '/');
  // }

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
            Row(
              children: [
                Text('$_scanCount'), // Display scan log count
                SizedBox(width: 5), // Add some spacing
                // if (_userId == "903") // Conditionally show the button
                IconButton(
                  onPressed: () {
                    // Navigate to the history page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScannedLogsHistoryPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.history),
                ),
                IconButton(
                  onPressed:
                      _uploadScanLogs, // Call _uploadScanLogs when pressed
                  icon: Icon(Icons.cloud_upload),
                ),
              ],
            ),
            // IconButton(
            //   onPressed: _uploadScanLogs, // Call _uploadScanLogs when pressed
            //   icon: Icon(Icons.cloud_upload),
            // ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isDownloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: scanLogs.length,
              itemBuilder: (context, index) {
                final log = scanLogs[index];
                return Card(
                  child: ListTile(
                    title: Text(
                        log['fullname'] + "(" + log["Department"] + ")" ??
                            'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Event: ${log['event_name'] ?? 'Unknown'}'),
                        Text(
                            'Date: ${log['date'] + " " + convertTo12HourFormat(log["time"]) ?? 'Unknown'}'),
                        Text('Remarks: ${log['remarks'] ?? 'Unknown'}'),
                        Text(
                            'Scanned By: ${log['scanner_fullname'] ?? 'Unknown'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: 2,
      //   onTap: (index) {
      //     if (index == 0) {
      //       Navigator.pushReplacementNamed(context, '/home');
      //     } else if (index == 1) {
      //       Navigator.pushReplacementNamed(context, '/employees');
      //     } else if (index == 3) {
      //       _showLogoutConfirmation(context);
      //     }
      //   },
      // ),
    );
  }
}
