import 'package:flutter/material.dart';
import 'screens/home/Home_screen.dart'; // Import your HomeScreen
import 'screens/home/Employees.dart'; // Import your HomeScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => HomeScreen(), // Define the route for HomeScreen
        '/employees': (context) =>
            EmployeesScreen(), // Define the route for EmployeesScreen
      },
      onGenerateRoute: (settings) {
        // Handle other routes here if needed
        return MaterialPageRoute(builder: (context) => NotFoundScreen());
      },
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Not Found'),
      ),
      body: Center(
        child: Text('Page Not Found'),
      ),
    );
  }
}
