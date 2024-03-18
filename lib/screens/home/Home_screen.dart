import 'package:flutter/material.dart';
import 'package:diary_app/repository/notes_repository.dart';
import 'package:diary_app/models/employee.dart';
import '../../layouts/bottom_nav_bar.dart'; // Import your BottomNavBar widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  List<Employee> searchResults = [];
  String currentEvent = 'None Stated'; // Default value for the current event

  @override
  void initState() {
    super.initState();
    fetchCurrentEvent(); // Fetch the current event when the screen initializes
  }

  Future<void> fetchCurrentEvent() async {
    try {
      // Fetch the current event from SQLite
      List<Map<String, dynamic>> events = await NoteRepository.callAllEvents();
      if (events.isNotEmpty) {
        setState(() {
          currentEvent = events.first['event_name'];
        });
      }
    } catch (e) {
      currentEvent = "No Event";
    }
  }

  Future<void> searchEmployee() async {
    String keyword = searchController.text.trim();
    if (keyword.isEmpty) {
      return;
    }

    List<Employee> employees = await NoteRepository.getEmployees();
    searchResults = employees
        .where((emp) =>
            emp.firstName.toLowerCase().contains(keyword.toLowerCase()) ||
            emp.lastName.toLowerCase().contains(keyword.toLowerCase()) ||
            emp.fingerId.toLowerCase() == keyword.toLowerCase())
        .toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home'),
            SizedBox(height: 4),
            Text('Event: $currentEvent', style: TextStyle(fontSize: 14)),
          ],
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by Finger ID, First Name, or Last Name',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: searchEmployee,
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            if (searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final employee = searchResults[index];
                    return Card(
                      child: ListTile(
                        title:
                            Text('${employee.firstName} ${employee.lastName}'),
                        subtitle: Text('Finger ID: ${employee.fingerId}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Handle IN button press
                              },
                              child: Text('IN'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                // Handle OUT button press
                              },
                              child: Text('OUT'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (searchResults.isEmpty)
              Expanded(
                child: Center(
                  child: Text('No employees found.'),
                ),
              ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => const AddNoteScreen()),
      //     );
      //   },
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   foregroundColor: Colors.white,
      //   child: const Icon(Icons.add),
      // ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Set the initial index of the bottom navigation bar
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(
                context, '/employees'); // Navigate to EmployeesScreen
          } else {
            // Navigate to HomeScreen or handle other cases as needed
          }
        },
      ),
    );
  }
}
