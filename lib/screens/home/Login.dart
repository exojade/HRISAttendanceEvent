import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/users.dart'; // Assuming you have a User model
import '../../repository/notes_repository.dart'; // Import your repository
import '../home/Home_screen.dart'; // Import your HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _login() async {
    if (!_isConnected) {
      // Show a message or dialog indicating no internet connection
      showNoInternetToast();
      return;
    }

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    bool isAuthenticated = await _authenticateUser(username, password);

    setState(() {
      _isLoading = false; // Set loading state back to false
    });

    if (isAuthenticated) {
      onLoginSuccess(); // Call the success handler
    } else {
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     title: Text('Login Failed'),
      //     content: Text('Invalid username or password.'),
      //     actions: [
      //       TextButton(
      //         onPressed: () => Navigator.pop(context),
      //         child: Text('OK'),
      //       ),
      //     ],
      //   ),
      // );
    }
  }

  Future<bool> _authenticateUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://203.177.88.234:7000/hris/mobileLogin'),
        body: jsonEncode({
          'employee': {'username': username, 'password': password},
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // print("sulod diri sa 200");
        var data = jsonDecode(response.body);
        // print(data);
        if (data['status'] == 'success' && data['employee'].isNotEmpty) {
          // print("tama credentials");
          var employeeData = data['employee'];
          String fullname = employeeData['fullname'];
          String userId = employeeData['user_id'].toString();

          await NoteRepository.insertUser(User(
            fullname: fullname,
            username: username,
            password: password, // This should be handled securely
            userId: userId,
          ));

          return true; // Authentication successful
        } else {
          // print("mali credentials");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Login Failed'),
              content: Text('Invalid username or password.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        showNoInternetToast();
      }
    } catch (e) {
      // print('Error authenticating user: $e');
      showNoInternetToast();
      // Handle internet connection error
    }

    return false; // Authentication failed
  }

  void onLoginSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void showNoInternetToast() {
    // print("No Internet Connection");
    Fluttertoast.showToast(
      msg: 'No internet connection',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WELCOME'),
        centerTitle: true,
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildLoginForm(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      // Wrap with SingleChildScrollView
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/login_image.png', // Replace with your image path
              width: 150, // Adjust the width as needed
              height: 150, // Adjust the height as needed
            ),
            SizedBox(height: 20.0),
            Text(
              'HR Attendance Monitoring for Events',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
