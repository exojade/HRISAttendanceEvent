import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/employee.dart';
import '../models/events.dart'; // Import the Event model

class NoteRepository {
  static const _dbName = 'hris.db';
  static const _tblemployees = 'tblemployees';
  static const _event = 'events';

  static Future<Database> _database() async {
    final dbPath = await getDatabasesPath();
    final database =
        openDatabase(join(dbPath, _dbName), onCreate: (db, version) {
      // Create the employees table
      db.execute(
          'CREATE TABLE $_tblemployees(Employeeid TEXT PRIMARY KEY, FirstName TEXT, LastName TEXT, Department TEXT, Fingerid TEXT)');

      // Create the events table
      db.execute('''
          CREATE TABLE $_event (
            event_id TEXT PRIMARY KEY,
            event_name TEXT
          )
          ''');

      // Create the scan_logs table if needed
      db.execute('''
          CREATE TABLE IF NOT EXISTS scan_logs (
            logs_id TEXT PRIMARY KEY,
            event_id TEXT,
            Employeeid TEXT,
            logs_date TEXT,
            logs_time TEXT,
            timestamp TEXT
          )
          ''');
    }, version: 1);
    return database;
  }

  static Future<void> deleteAllEmployees() async {
    final db = await _database();
    await db.delete(_tblemployees); // Delete all rows from the employees table
  }

  static Future<void> deleteActiveEvent() async {
    final db = await _database();
    await db.delete(_event); // Delete all rows from the events table
  }

  static Future<int> getEmployeeCount() async {
    try {
      final db = await _database();
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $_tblemployees'));
      return count ?? 0;
    } catch (e) {
      print('Error getting employee count: $e');
      return 0;
    }
  }

  static Future<bool> employeeExists(String searchKeyword) async {
    try {
      final db = await _database();
      final count = Sqflite.firstIntValue(await db.rawQuery(
          "SELECT COUNT(*) FROM $_tblemployees WHERE Employeeid = ? OR FirstName LIKE ? OR LastName LIKE ?",
          [searchKeyword, '%$searchKeyword%', '%$searchKeyword%']));
      return count != null && count > 0;
    } catch (e) {
      print('Error checking employee existence: $e');
      return false;
    }
  }

  static Future<List<Employee>> searchEmployees(String searchKeyword) async {
    try {
      final db = await _database();
      final List<Map<String, dynamic>> employeeData = await db.rawQuery(
          "SELECT * FROM $_tblemployees WHERE Employeeid = ? OR FirstName LIKE ? OR LastName LIKE ?",
          [searchKeyword, '%$searchKeyword%', '%$searchKeyword%']);

      return List.generate(employeeData.length, (index) {
        return Employee(
          id: employeeData[index]['Employeeid'],
          firstName: employeeData[index]['FirstName'],
          lastName: employeeData[index]['LastName'],
          department: employeeData[index]['Department'],
          fingerId: employeeData[index]['Fingerid'],
        );
      });
    } catch (e) {
      print('Error searching employees: $e');
      return []; // Return an empty list if there's an error
    }
  }

  static Future<void> insertToEmployees(
      List<Map<String, dynamic>> employees) async {
    final db = await _database();

    // Generate the values section of the SQL query
    List<String> valueStrings = employees.map((employee) {
      return "('${employee['Employeeid']}', '${employee['FirstName']}', '${employee['LastName']}', '${employee['Department']}', '${employee['Fingerid']}')";
    }).toList();

    // Generate the full SQL INSERT query
    String query =
        "INSERT INTO $_tblemployees (Employeeid, FirstName, LastName, Department, Fingerid) VALUES ${valueStrings.join(',')}";

    await db.rawInsert(query);
  }

  static Future<void> insertToEvents(List<Map<String, dynamic>> events) async {
    final db = await _database();

    // Generate the values section of the SQL query
    List<String> valueStrings = events.map((event) {
      return "('${event['event_id']}', '${event['event_name']}')";
    }).toList();

    // Generate the full SQL INSERT query
    String query =
        "INSERT INTO $_event (event_id, event_name) VALUES ${valueStrings.join(',')}";

    await db.rawInsert(query);
  }

  static Future<List<Map<String, dynamic>>> callAllEmployees() async {
    final db = await _database();
    var res = await db.rawQuery("SELECT * FROM $_tblemployees");
    return res;
  }

  static Future<List<Employee>> getEmployees() async {
    final db = await _database();
    final List<Map<String, dynamic>> maps = await db.query(_tblemployees);
    return List.generate(maps.length, (index) {
      return Employee(
        id: maps[index]['Employeeid'],
        firstName: maps[index]['FirstName'],
        lastName: maps[index]['LastName'],
        department: maps[index]['Department'],
        fingerId: maps[index]['Fingerid'],
      );
    });
  }
}
