import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:diary_app/repository/notes_repository.dart';
import 'package:diary_app/models/employee.dart';
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
      final response = await http
          .get(Uri.parse('http://192.168.1.21:81/hris/fetchEmployees'));
      if (response.statusCode == 200) {
        List<Employee> employees =
            (json.decode(response.body)['employees'] as List)
                .map((data) => Employee.fromJson(data))
                .toList();

        // Delete existing data from tblemployees in SQLite
        await NoteRepository.deleteAllEmployees();

        // Insert new data into tblemployees in SQLite
        List<Map<String, dynamic>> employeeData =
            employees.map((employee) => employee.toJson()).toList();
        await NoteRepository.insertToEmployees(employeeData);

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

  Future<void> downloadEmployees() async {
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
            onPressed: downloadEmployees,
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
