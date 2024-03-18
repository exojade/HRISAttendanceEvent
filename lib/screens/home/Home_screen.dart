import 'package:flutter/material.dart';
import 'package:diary_app/repository/notes_repository.dart';
import 'package:diary_app/models/employee.dart';
import 'package:diary_app/models/events.dart';
import 'package:diary_app/models/scan_logs.dart'; // Import the ScanLogs model
import '../../layouts/bottom_nav_bar.dart'; // Import your BottomNavBar widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  List<Employee> searchResults = [];
  String currentEvent = 'None Stated'; // Default value for the current event
  String currentEventid = '0'; // Default value for the current event

  @override
  void initState() {
    super.initState();
    fetchCurrentEvent(); // Fetch the current event when the screen initializes
  }

  Future<void> fetchCurrentEvent() async {
    try {
      // Fetch the current event from SQLite
      List<Map<String, dynamic>> events = await NoteRepository.callAllEvents();
      if (events.isNotEmpty) {
        setState(() {
          currentEvent = events.first['event_name'];
          currentEventid = events.first['event_id'];
        });
      }
    } catch (e) {
      currentEvent = "No Event";
    }
  }

  Future<void> searchEmployee() async {
    String keyword = searchController.text.trim();
    if (keyword.isEmpty) {
      return;
    }

    List<Employee> employees = await NoteRepository.getEmployees();
    searchResults = employees
        .where((emp) =>
            emp.firstName.toLowerCase().contains(keyword.toLowerCase()) ||
            emp.lastName.toLowerCase().contains(keyword.toLowerCase()) ||
            emp.fingerId.toLowerCase() == keyword.toLowerCase())
        .toList();

    // Check if employee has already scanned for the current event
    await checkScanLogs(searchResults);

    setState(() {});
  }

  Future<void> checkScanLogs(List<Employee> employees) async {
    for (Employee emp in employees) {
      bool hasScannedIn =
          await NoteRepository.checkScanLog(emp.id, currentEventid, 'IN');
      bool hasScannedOut =
          await NoteRepository.checkScanLog(emp.id, currentEventid, 'OUT');
      if (hasScannedIn) {
        setState(() {
          emp.hasScannedIn = true; // Mark employee as scanned in
        });
      }
      if (hasScannedOut) {
        setState(() {
          emp.hasScannedOut = true; // Mark employee as scanned out
        });
      }
    }
  }

  void handleScanLogPress(
      String eventId, String employeeId, String remarks) async {
    bool hasScannedIn =
        await NoteRepository.checkScanLog(employeeId, eventId, 'IN');
    bool hasScannedOut =
        await NoteRepository.checkScanLog(employeeId, eventId, 'OUT');

    if (remarks == 'IN' && hasScannedIn) {
      // Show alert or toast that employee has already scanned in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee has already scanned in!')),
      );
    } else if (remarks == 'OUT' && hasScannedOut) {
      // Show alert or toast that employee has already scanned out
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee has already scanned out!')),
      );
    } else {
      // Insert scan log based on remarks
      await NoteRepository.insertScanLog(eventId, employeeId, remarks);
      // Refresh search results
      searchEmployee();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home'),
            SizedBox(height: 4),
            Text('Event: $currentEvent', style: TextStyle(fontSize: 14)),
          ],
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by Finger ID, First Name, or Last Name',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: searchEmployee,
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            if (searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final employee = searchResults[index];
                    return Card(
                      child: ListTile(
                        title:
                            Text('${employee.firstName} ${employee.lastName}'),
                        subtitle: Text('Finger ID: ${employee.fingerId}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                handleScanLogPress(
                                    currentEventid, employee.id, 'IN');
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) {
                                    if (employee.hasScannedIn) {
                                      return Colors.red;
                                    }
                                    return null; // Use default color
                                  },
                                ),
                              ),
                              child: Text('IN'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                handleScanLogPress(
                                    currentEventid, employee.id, 'OUT');
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) {
                                    if (employee.hasScannedOut) {
                                      return Colors.red;
                                    }
                                    return null; // Use default color
                                  },
                                ),
                              ),
                              child: Text('OUT'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (searchResults.isEmpty)
              Expanded(
                child: Center(
                  child: Text('No employees found.'),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Set the initial index of the bottom navigation bar
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(
                context, '/employees'); // Navigate to EmployeesScreen
          } else if (index == 2) {
            Navigator.pushReplacementNamed(
                context, '/scan_logs'); // Navigate to ScannedLogsScreen
          } else {
            // Handle other cases as needed
          }
        },
      ),
    );
  }
}


