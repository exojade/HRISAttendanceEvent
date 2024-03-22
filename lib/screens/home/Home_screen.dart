import 'package:flutter/material.dart';
import 'package:diary_app/repository/notes_repository.dart';
import 'package:diary_app/models/employee.dart';
import 'package:diary_app/models/events.dart';
import 'package:diary_app/models/users.dart';
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
  String currentEventid = '0';
  String loggedInUserName = '';
  String loggedInUserId = '';
  // Default value for the current event

  @override
  void initState() {
    super.initState();
    fetchCurrentEvent(); // Fetch the current event when the screen initializes
    fetchLoggedInUser();
  }

  Future<void> fetchLoggedInUser() async {
    try {
      List<User> users = await NoteRepository.getUsers();
      if (users.isNotEmpty) {
        setState(() {
          loggedInUserName = users.first.fullname;
          loggedInUserId = users.first.userId;
        });
      }
    } catch (e) {
      print('Error fetching logged-in user: $e');
    }
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
      keyword = "000000000000";
      // return;
    }

    List<Employee> employees = await NoteRepository.getEmployees();
    searchResults = employees.where((emp) {
      // Convert first name and last name to lowercase for case-insensitive comparison
      String fullName = '${emp.firstName} ${emp.lastName}'.toLowerCase();
      String Fingerid = '${emp.fingerId}'.toLowerCase();
      // print(fullName);
      String reversedFullName =
          '${emp.lastName} ${emp.firstName}'.toLowerCase();
      String keywordLower = keyword.toLowerCase();

      return fullName
              .contains(keywordLower) || // Search by firstName + lastName
          reversedFullName
              .contains(keywordLower) || // Search by lastName + firstName
          Fingerid == keywordLower; // Search by finger ID
    }).toList();

    // Check if employee has already scanned for the current event
    await checkScanLogs(searchResults);

    setState(() {
      // Clear the search text field and refocus it
      // searchController.clear();
      // FocusScope.of(context).requestFocus(FocusNode());
    });
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
                // Perform logout actions here, such as clearing data
                // and navigating back to the login screen
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    // Clear user-related data from SQLite
    await NoteRepository.deleteUsers();

    // Clear other data as needed
    // await NoteRepository.deleteOtherData();

    // Navigate back to login screen
    Navigator.pushReplacementNamed(context, '/');
  }

  void handleScanLogPress(
      String eventId, String employeeId, String remarks) async {
    bool hasScannedIn =
        await NoteRepository.checkScanLog(employeeId, eventId, 'IN');
    bool hasScannedOut =
        await NoteRepository.checkScanLog(employeeId, eventId, 'OUT');

    if (remarks == 'IN' && hasScannedIn) {
      // Show alert or toast that employee has already scanned in
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Employee has already scanned in!')),
      // );
      showUndoDialog(eventId, employeeId, "IN");
    } else if (remarks == 'OUT' && hasScannedOut) {
      // Show alert or toast that employee has already scanned out
      showUndoDialog(eventId, employeeId, "OUT");
    } else {
      // Insert scan log based on remarks
      await NoteRepository.insertScanLog(
          eventId, employeeId, remarks, loggedInUserId);
      // Refresh search results
      searchEmployee();
    }
  }

  void showUndoDialog(String eventId, String employeeId, String Remarks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Undo'),
          content: Text('Are you sure you want to undo this scan log?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Perform the undo operation here
                bool success = await NoteRepository.undoScanLog(
                    employeeId, eventId, Remarks);
                if (success) {
                  Navigator.of(context).pop(); // Close the dialog
                  // Show a success message or update UI as needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Scan log undone successfully!')),
                  );
                  searchEmployee();
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  // Show an error message or handle the failure
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to undo scan log!')),
                  );
                  searchEmployee();
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0), // Set the preferred height
        child: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, $loggedInUserName'),
            ],
          ),
          centerTitle: false,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Event: $currentEvent', style: TextStyle(fontSize: 14)),
            TextField(
              controller: searchController,
              onChanged: (value) {
                // Call the search function here passing the updated value
                searchEmployee();
              },
              decoration: InputDecoration(
                hintText: 'Search by Finger ID, First Name, or Last Name',
                // suffixIcon: IconButton(
                //   icon: Icon(Icons.clear),
                //   onPressed: () {
                //     setState(() {
                //       searchController.clear();
                //       searchEmployee();
                //     });
                //   },
                // ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  searchController.clear();
                  searchEmployee();
                });
              },
              child: Text('Clear'),
            ),
            SizedBox(height: 20),
            if (searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final employee = searchResults[index];
                    return GestureDetector(
                      onTap: () {
                        // handleScanLogPress(currentEventid, employee.id, 'IN');
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(
                              '${employee.firstName} ${employee.lastName}'),
                          subtitle: Text(
                            '(${employee.department}) ID: ${employee.fingerId} ',
                          ),
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
          } else if (index == 3) {
            _showLogoutConfirmation(context);
            // Navigate to ScannedLogsScreen
          } else {
            // Handle other cases as needed
          }
        },
      ),
    );
  }
}
