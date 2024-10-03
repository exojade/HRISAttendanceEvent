import 'package:flutter/material.dart';
import 'repository/notes_repository.dart'; // Import your NoteRepository
import 'screens/home/Home_screen.dart'; // Import your HomeScreen
import 'screens/home/Employees.dart'; // Import your EmployeesScreen
import 'screens/home/Scanned.dart'; // Import your ScannedLogsScreen
import 'screens/home/Login.dart'; // Import your LoginScreen
import 'screens/home/Profile.dart'; // Import your LoginScreen
import 'layouts/bottom_nav_bar.dart'; // Import your BottomNavBar widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  try {
    // Initialize the database and get the user count
    await NoteRepository.initDatabase();
    int userCount = await NoteRepository.getUserCount();
    print("USERCOUNT $userCount");

    runApp(MaterialApp(
      // title: 'My App',
      home: MyApp(userCount: userCount),
    ));
  } catch (e) {
    print("Error during initialization: $e");
  }
}

class MyApp extends StatefulWidget {
  final int userCount;

  const MyApp({Key? key, required this.userCount}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  int _userCount = 0;

  @override
  void initState() {
    super.initState();
    _updateUserCount(); // Initialize userCount
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // if (_currentIndex == 3) {
    //   _logout(
    //       context); // Logout when tapping on a specific index, for example, index 3
    // }
  }

  // void _logout(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Confirm Logout'),
  //       content: Text('Are you sure you want to logout?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context); // Close the dialog
  //           },
  //           child: Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             // Clear user-related data from SQLite
  //             await NoteRepository.deleteUsers();

  //             // Call _onLogoutSuccess to update user count
  //             _onLogoutSuccess();

  //             // Close the dialog and navigate to login screen
  //             Navigator.pop(context); // Close the dialog
  //           },
  //           child: Text('Logout'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _updateUserCount() async {
    int userCount = await NoteRepository.getUserCount();
    setState(() {
      _userCount = userCount;
      _currentIndex = 0;
    });
  }

  void _onLogoutSuccess() async {
    // Update user count to 0
    int userCount = await NoteRepository.getUserCount();
    _updateUserCount();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        // appBar: AppBar(
        //   title: Text('My App'),
        // ),
        body: _buildBody(),
        bottomNavigationBar: _userCount > 0
            ? BottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onTap,
              )
            : null, // Hide bottom navigation if userCount is 0
      ),
      // Define your routes here
      routes: {
        '/home': (context) => HomeScreen(),
        '/employees': (context) => EmployeesScreen(),
        '/scan_logs': (context) => ScannedLogsScreen(),
        '/profile': (context) => ProfilePage(logoutCallback: _logout),
        '/login': (context) => LoginScreen(onLoginSuccess: _updateUserCount),
      },
      initialRoute: '/', // Set the initial route
      onGenerateRoute: (settings) {
        // Handle unknown routes here
        return MaterialPageRoute(builder: (context) => NotFoundScreen());
      },
    );
  }

  Widget _buildBody() {
    if (_userCount == 0) {
      return LoginScreen(onLoginSuccess: _updateUserCount);
    } else {
      switch (_currentIndex) {
        case 0:
          return HomeScreen();
        case 1:
          return EmployeesScreen();
        case 2:
          return ScannedLogsScreen();
        default:
          return ProfilePage(
              logoutCallback: _logout); // Replace this with your default page
      }
    }
  }

  // void _onLogoutButtonPressed(BuildContext context) {
  //   _logout(context);
  // }

  void _logout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () async {
              await NoteRepository.deleteUsers();
              await NoteRepository.initDatabase();
              _onLogoutSuccess();
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('No'),
          ),
        ],
      ),
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
