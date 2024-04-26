import 'package:flutter/material.dart';
import '../../repository/notes_repository.dart'; // Import your repository
import 'package:diary_app/models/scan_logs.dart'; // Import the ScanLogs model
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannedLogsHistoryPage extends StatefulWidget {
  @override
  _ScannedLogsHistoryPageState createState() => _ScannedLogsHistoryPageState();
}

class _ScannedLogsHistoryPageState extends State<ScannedLogsHistoryPage> {
  List<Map<String, dynamic>> _scannedLogs = []; // List to store scanned logs

  List<String> _uniqueDates = [];
  String? _selectedDate;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _fetchScannedLogs(); // Fetch scanned logs when the page initializes
  }

  Future<void> _fetchScannedLogs() async {
    try {
      // Fetch scanned logs from the repository
      List<Map<String, dynamic>> logs =
          await NoteRepository.getHistoryScanLogs();
      setState(() {
        _scannedLogs = logs; // Update the state with the fetched logs
        _uniqueDates = _extractUniqueDates(logs);
      });
    } catch (e) {
      // print('Error fetching scanned logs: $e');
      // Handle error fetching scanned logs
    }
  }

  List<String> _extractUniqueDates(List<Map<String, dynamic>> logs) {
    // Extract dates from logs and convert to set to get unique dates
    Set<String> uniqueDates = logs.map((log) => log['date'] as String).toSet();
    return uniqueDates.toList();
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

  void _reuploadLogs() {
    if (_selectedDate != null) {
      // Filter logs for the selected date
      List<Map<String, dynamic>> logsForDate =
          _scannedLogs.where((log) => log['date'] == _selectedDate).toList();

      // Call the reupload process with logsForDate
      _uploadLogs(logsForDate);
    }
  }

  void _uploadLogs(List<Map<String, dynamic>> logs) async {
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return Center(
    //       child: CircularProgressIndicator(),
    //     );
    //   },
    // );
    setState(() {
      _isDownloading = true; // Set downloading flag to true
    });

    try {
      // Convert logs data to JSON format
      String jsonData = jsonEncode(logs);
      // print(jsonData);

      // Make POST request to the API endpoint
      final response = await http.post(
        Uri.parse('http://203.177.88.234:7000/hris/insertLogs'),
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
        _fetchScannedLogs();
        // print('Logs uploaded successfully');
        // Display success message
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: Text('Success'),
        //       content: Text('Logs uploaded successfully'),
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
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to upload logs. Status code: ${response.statusCode}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        _fetchScannedLogs();

        // Display error message
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
      Fluttertoast.showToast(
        msg: 'Failed to upload logs. Status code: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      _fetchScannedLogs();
      // print('Error uploading logs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanned Logs History'),
        centerTitle: true,
      ),
      body: _isDownloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedDate,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDate = newValue!;
                          });
                        },
                        items: _uniqueDates.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _reuploadLogs();
                      },
                      child: Text('REUPLOAD'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        NoteRepository.deleteArchiveLogs(_selectedDate);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('deleted')),
                        );
                        _fetchScannedLogs();
                      },
                      child: Text('DELETE'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _scannedLogs.length,
                    itemBuilder: (context, index) {
                      final log = _scannedLogs[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            log['fullname'] + "(" + log["Department"] + ")" ??
                                'Unknown',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Event: ${log['event_name'] ?? 'Unknown'}'),
                              Text(
                                'Date: ${log['date'] + " " + convertTo12HourFormat(log["time"]) ?? 'Unknown'}',
                              ),
                              Text('Remarks: ${log['remarks'] ?? 'Unknown'}'),
                              Text(
                                  'Scanned By: ${log['scanner_fullname'] ?? 'Unknown'}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
