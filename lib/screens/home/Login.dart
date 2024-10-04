import 'dart:convert';
import 'package:diary_app/main.dart';
import 'package:diary_app/models/serverUrl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/users.dart'; // Assuming you have a User model
import '../../repository/notes_repository.dart'; // Import your repository
import '../home/Home_screen.dart'; // Import your HomeScreen

class LoginScreen extends StatefulWidget {
  final Function()
      onLoginSuccess; // Callback function to execute on successful login

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _serverController =
      TextEditingController(text: 'http://panabocityeternalgarden.online');
  bool _isLoading = false;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    fetchServerDatatable();
  }

  Future<void> fetchServerDatatable() async {
    await NoteRepository.addServerTable();
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
    String serverUrl = _serverController.text.trim();

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    bool isAuthenticated =
        await _authenticateUser(username, password, serverUrl);

    setState(() {
      _isLoading = false; // Set loading state back to false
    });

    if (isAuthenticated) {
      widget.onLoginSuccess();
      // onLoginSuccess(); // Call the success handler
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

  Future<bool> _authenticateUser(
      String username, String password, String serverUrl) async {
    try {
      String theUrl = serverUrl + '/hris/mobileLogin';
      print(theUrl);
      final response = await http.post(
        Uri.parse(theUrl),
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

          await NoteRepository.inserServerUrl(ServerUrl(serverUrl: serverUrl));

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

  // void onLoginSuccess() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => HomeScreen()),
  //   );
  // }

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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/login_image.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'HRIS Mobile Attendance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username *',
                labelStyle: const TextStyle(
                    color: Colors.grey), // Grey color for label text
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Colors.grey), // Default border color
                  borderRadius:
                      BorderRadius.circular(10.0), // Optional rounded corners
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFF22428E), width: 2.0), // Color on focus
                  borderRadius:
                      BorderRadius.circular(10.0), // Optional rounded corners
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Optional rounded corners
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password *',
                labelStyle: const TextStyle(
                    color: Colors.grey), // Grey color for label text
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Colors.grey), // Default border color
                  borderRadius:
                      BorderRadius.circular(10.0), // Optional rounded corners
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFF22428E), width: 2.0), // Color on focus
                  borderRadius:
                      BorderRadius.circular(10.0), // Optional rounded corners
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Optional rounded corners
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _serverController,
              decoration: InputDecoration(
                labelText: 'Server Url *',
                labelStyle: const TextStyle(
                    color: Colors.grey), // Grey color for label text
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Colors.grey), // Default border color
                  borderRadius:
                      BorderRadius.circular(10.0), // Optional rounded corners
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFF22428E), width: 2.0), // Color on focus
                  borderRadius:
                      BorderRadius.circular(10.0), // Optional rounded corners
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Optional rounded corners
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _login,
              child: const Text('LOGIN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22428E),
                foregroundColor: Colors.white, // Set the background color
                minimumSize: const Size(double.infinity,
                    50), // Stretch button to fill width and set height
              ),
            ),
          ],
        ),
      ),
    );
  }
}
