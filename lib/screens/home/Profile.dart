import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:diary_app/models/users.dart';
import 'package:diary_app/models/version.dart';
import '../../repository/notes_repository.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// import 'models/users.dart'; // Import your User model
String version_string = '';

bool _isLoading = false;
bool _isConnected = true;

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
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> fetchVersion() async {
    await NoteRepository.addVersionTable();

    try {
      List<Version> version_table = await NoteRepository.getVersion();
      if (version_table.isNotEmpty) {
        setState(() {
          version_string = version_table.first.version;
        });
      } else {
        await NoteRepository.insertIntoVersion("1");
        version_table = await NoteRepository.getVersion();
        setState(() {
          version_string = version_table.first.version;
        });
      }
    } catch (e) {
      print('Error fetching logged-in user: $e');
    }
  }

  Future<bool> checkForUpdates(String version) async {
    try {
      final response = await http.post(
        Uri.parse('http://203.177.88.234:7000/hris/checkUpdates'),
        body: jsonEncode({
          'versionBody': {'version': version},
        }),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // print("sulod diri sa 200");
        var data = jsonDecode(response.body);
        print(data);
        if (data['status'] == 'success' && data['responsive'].isNotEmpty) {
          // print("tama credentials");
          var responseData = data['responsive'];
          print(responseData['google_link']);
          _showUpdateDialog(responseData['google_link']);
          if (responseData["responseStatus"] == 1) {
            _showUpdateDialog(data['google_link']);
          } else {
            _showNoUpdateDialog();
          }

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
        // showNoInternetToast();
      }
    } catch (e) {
      // print('Error authenticating user: $e');
      // showNoInternetToast();
      // Handle internet connection error
    }

    return false; // Authentication failed
  }

  Future<void> _checker() async {
    // if (!_isConnected) {
    //   // Show a message or dialog indicating no internet connection
    //   showNoInternetToast();
    //   return;
    // }

    // setState(() {
    //   _isLoading = true; // Set loading state to true
    // });

    bool isAuthenticated = await checkForUpdates(version_string);

    setState(() {
      _isLoading = false; // Set loading state back to false
    });
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

  void _showUpdateDialog(String downloadLink) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Available"),
          content: Text(
              "A new version of the app is available. Would you like to download it?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchURL(downloadLink);
              },
              child: Text("Download"),
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showNoUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No Updates"),
          content: Text("Your app is up to date."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
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
                        "App Version: " + version_string,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: widget.logoutCallback,
                        child: Text('Logout'),
                      ),
                      ElevatedButton(
                        onPressed: _checker,
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
