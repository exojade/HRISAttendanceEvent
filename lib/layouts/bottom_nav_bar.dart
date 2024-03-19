import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.white.withOpacity(0.6),
      type: BottomNavigationBarType.fixed, // Ensure fixed background color
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Employees',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Scan Logs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout), // Add logout button
          label: 'Logout',
        ),
      ],
    );
  }
}
