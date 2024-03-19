import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/users.dart'; // Assuming you have a User model
import '../../repository/notes_repository.dart'; // Import your repository

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Perform authentication with the web API
    bool isAuthenticated = await _authenticateUser(username, password);
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(
          context, '/home'); // Redirect to home screen
    } else {
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
        var data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['employee'].isNotEmpty) {
          // Insert user data into SQLite
          await NoteRepository.insertUser(User.fromJson(data['employee']));
          return true; // Authentication successful
        }
      }
    } catch (e) {
      print('Error authenticating user: $e');
    }
    return false; // Authentication failed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
