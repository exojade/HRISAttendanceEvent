import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../repository/notes_repository.dart';
import 'package:diary_app/models/employee.dart';
import 'package:diary_app/models/events.dart'; // Import the Event model
import '../../layouts/bottom_nav_bar.dart'; // Import the BottomNavBar widget

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({Key? key}) : super(key: key);

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  int _currentIndex = 1; // Index for EmployeesScreen
  bool _isDownloading = false; // Flag to track download state

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



  Future<void> fetchDataAndSync() async {
    try {
      setState(() {
        _isDownloading = true; // Set downloading flag to true
      });

      final employeeResponse = await http
          .get(Uri.parse('http://203.177.88.234:7000/hris/fetchEmployees'));
      final eventResponse = await http
          .get(Uri.parse('http://203.177.88.234:7000/hris/fetchEventActive'));

      if (employeeResponse.statusCode == 200 &&
          eventResponse.statusCode == 200) {
        List<Employee> employees =
            (json.decode(employeeResponse.body)['employees'] as List)
                .map((data) => Employee.fromJson(data))
                .toList();

        List<ActiveEvent> events =
            (json.decode(eventResponse.body)['event'] as List)
                .map((data) => ActiveEvent.fromJson(data))
                .toList();

        // Delete existing data from tables in SQLite
        await NoteRepository.deleteAllEmployees();
        await NoteRepository.deleteActiveEvent();

        // Insert new data into tables in SQLite
        List<Map<String, dynamic>> employeeData =
            employees.map((employee) => employee.toJson()).toList();
        List<Map<String, dynamic>> eventData =
            events.map((event) => event.toJson()).toList();

        await NoteRepository.insertToEmployees(employeeData);
        await NoteRepository.insertToEvents(eventData);

        // Update the UI
        setState(() {
          _isDownloading = false; // Set downloading flag to false
        });

        // Get and show employee count
        int count = await NoteRepository.getEmployeeCount();
        // showEmployeeCountToast(count);
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        _isDownloading = false; // Set downloading flag to false on error
      });
      print('Error fetching and syncing data: $e');
    }
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      switch (_currentIndex) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          // Do nothing, already on EmployeesScreen
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/scan_logs');
          break;
        case 3:
          _showLogoutConfirmation(context);
          break;
     
        default:
          break;
      }
    });
  }

  Future<void> downloadData() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing on outside tap
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Downloading data..."),
              ],
            ),
          ),
        );
      },
    );

    void _logout() async {
  // Clear user-related data from SQLite
  await NoteRepository.deleteUsers();
  
  // Clear other data as needed
  // await NoteRepository.deleteOtherData();

  // Navigate back to login screen
  Navigator.pushReplacementNamed(context, '/');
}

    await fetchDataAndSync(); // Call your fetch data method

    // Close the dialog when data is fetched
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: fetchDataAndSync,
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: downloadData,
            icon: Icon(Icons.file_download),
          ),
        ],
      ),
      body: _isDownloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder<List<Employee>>(
              future: NoteRepository.getEmployees(),
              builder: (context, AsyncSnapshot<List<Employee>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      padding: EdgeInsets.all(15),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final employee = snapshot.data![index];
                        return ListTile(
                          title:
                              Text('${employee.firstName} ${employee.lastName}'),
                          subtitle: Text(employee.department),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text("No employees found."),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarItemTapped,
      ),
    );
  }
}
