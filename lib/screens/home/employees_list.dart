import 'package:flutter/material.dart';
import '../../models/employee.dart'; // Import your Employee model

class EmployeeList extends StatelessWidget {
  final List<Employee> employees;

  const EmployeeList({Key? key, required this.employees}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: employees.length,
      itemBuilder: (context, index) {
        Employee employee = employees[index];
        return ListTile(
          title: Text('${employee.firstName} ${employee.lastName}'),
          subtitle: Text(employee.department),
          leading: CircleAvatar(
            child: Text(employee.firstName[0] + employee.lastName[0]),
          ),
          // Add more information or actions as needed
          onTap: () {
            // Handle employee tap
          },
        );
      },
    );
  }
}
