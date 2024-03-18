class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String department;
  final String fingerId;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.department,
    required this.fingerId,
  });

  // Factory method to create an Employee object from a JSON map
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['Employeeid'].toString(), // Ensure id is converted to string
      firstName: json['FirstName'].toString(),
      lastName: json['LastName'].toString(),
      department: json['Department'].toString(),
      fingerId: json['Fingerid'].toString(),
    );
  }

  // Convert an Employee object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Employeeid': id,
      'FirstName': firstName,
      'LastName': lastName,
      'Department': department,
      'Fingerid': fingerId,
    };
  }
}
