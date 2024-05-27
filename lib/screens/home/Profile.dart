import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:diary_app/models/users.dart';
import 'package:diary_app/models/version.dart';
import '../../repository/notes_repository.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// import 'models/users.dart'; // Import your User model
String version_string = '';

class ProfilePage extends StatefulWidget {
  final VoidCallback logoutCallback;

  const ProfilePage({Key? key, required this.logoutCallback}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    fetchVersion(); // Fetch the current event when the screen initializes
  }

  Future<void> fetchVersion() async {
    try {
      List<Version> version_table = await NoteRepository.getVersion();
      if (version_table.isNotEmpty) {
        setState(() {
          version_string = version_table.first.version;
        });
      } else {
        await NoteRepository.insertIntoVersion("1");
        version_table = await NoteRepository.getVersion();
        version_string = version_table.first.version;
      }
    } catch (e) {
      print('Error fetching logged-in user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              // Add profile picture here
              backgroundImage: AssetImage('assets/images/user-avatar.png'),
              radius: 100, // Adjust the size as needed
              backgroundColor: Colors.grey,
            ),
          ),
          SizedBox(height: 20),
          FutureBuilder<List<User>>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                List<User> users = snapshot.data!;
                if (users.isNotEmpty) {
                  User user = users.first;
                  return Column(
                    children: [
                      Text(
                        user.fullname,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        version_string,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: widget.logoutCallback,
                        child: Text('Logout'),
                      ),
                      ElevatedButton(
                        onPressed: widget.logoutCallback,
                        child: Text('Check Updates'),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: Text('No user data available'),
                  );
                }
              } else {
                return Center(
                  child: Text('No data available'),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<List<User>> _getUserData() async {
    try {
      List<User> users = await NoteRepository.getUsers();
      return users;
    } catch (e) {
      print('Error fetching logged-in user: $e');
      return []; // Return an empty list in case of error
    }
  }

  // Future<User> _getUserData() async {
  //   // Fetch user data from repository
  //   List<User> user = await NoteRepository.getUsers();
  //   return user;
  // }
}
