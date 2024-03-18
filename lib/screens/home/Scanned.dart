import 'package:flutter/material.dart';
import 'package:diary_app/repository/notes_repository.dart';
import '../../layouts/bottom_nav_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanned Logs'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: scanLogs.length,
        itemBuilder: (context, index) {
          final log = scanLogs[index];
          return Card(
            child: ListTile(
              title: Text(log['fullname'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event: ${log['event_name'] ?? 'Unknown'}'),
                  Text('Date: ${log['date'] ?? 'Unknown'}'),
                  Text('Remarks: ${log['remarks'] ?? 'Unknown'}'),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // Set the index for the current screen
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(
                context, '/'); // Navigate to HomeScreen
          } else if (index == 1) {
            Navigator.pushReplacementNamed(
                context, '/employees'); // Navigate to EmployeesScreen
          } else if (index == 3) {
            Navigator.pushReplacementNamed(
                context, '/notifications'); // Navigate to NotificationsScreen
          } else if (index == 4) {
            Navigator.pushReplacementNamed(
                context, '/profile'); // Navigate to ProfileScreen
          }
        },
      ),
    );
  }
}
