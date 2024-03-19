import 'package:flutter/material.dart';
import 'repository/notes_repository.dart'; // Import your NoteRepository
import 'screens/home/Home_screen.dart'; // Import your HomeScreen
import 'screens/home/Employees.dart'; // Import your EmployeesScreen
import 'screens/home/Scanned.dart'; // Import your ScannedLogsScreen
import 'screens/home/Login.dart'; // Import your LoginScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  // Initialize the database and get the user count
  await NoteRepository.initDatabase();
  int userCount = await NoteRepository.getUserCount();

  runApp(MyApp(userCount: userCount));
}

class MyApp extends StatelessWidget {
  final int userCount;

  const MyApp({Key? key, required this.userCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: userCount > 0 ? HomeScreen() : LoginScreen(), // Set home based on user count
      routes: {
        '/home': (context) => HomeScreen(),
        '/employees': (context) => EmployeesScreen(),
        '/scan_logs': (context) => ScannedLogsScreen(),
        '/': (context) => LoginScreen(),
      },
      onGenerateRoute: (settings) {
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
