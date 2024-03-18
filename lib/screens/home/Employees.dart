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

  Future<void> fetchDataAndSync() async {
    try {
      final employeeResponse = await http
          .get(Uri.parse('http://192.168.1.21:81/hris/fetchEmployees'));
      final eventResponse = await http
          .get(Uri.parse('http://192.168.1.21:81/hris/fetchEventActive'));

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
        setState(() {});

        // Get and show employee count
        int count = await NoteRepository.getEmployeeCount();
        // showEmployeeCountToast(count);
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error fetching and syncing data: $e');
    }
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      switch (_currentIndex) {
        case 0:
          Navigator.pushReplacementNamed(context, '/');
          break;
        case 1:
          // Do nothing, already on EmployeesScreen
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/scan_logs');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/notifications');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
        default:
          break;
      }
    });
  }

  Future<void> downloadData() async {
    await fetchDataAndSync(); // Call your fetch data method
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
      body: FutureBuilder<List<Employee>>(
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
                    title: Text('${employee.firstName} ${employee.lastName}'),
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
