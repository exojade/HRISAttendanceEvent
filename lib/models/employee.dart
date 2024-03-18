class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String department;
  final String fingerId;
  bool hasScannedIn;
  bool hasScannedOut;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.department,
    required this.fingerId,
    this.hasScannedIn = false,
    this.hasScannedOut = false,
  });

  // Factory method to create an Employee object from a JSON map
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['Employeeid'].toString(), // Ensure id is converted to string
      firstName: json['FirstName'].toString(),
      lastName: json['LastName'].toString(),
      department: json['Department'].toString(),
      fingerId: json['Fingerid'].toString(),
      hasScannedIn: json['hasScannedIn'] ?? false,
      hasScannedOut: json['hasScannedOut'] ?? false,
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
      'hasScannedIn': hasScannedIn,
      'hasScannedOut': hasScannedOut
    };
  }
}
