import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/employee.dart';
import '../models/events.dart';

class NoteRepository {
  static const _dbName = 'hris.db';
  static const _tblemployees = 'tblemployees';
  static const _event = 'events';
  // static const _tableName = 'tblemployees';

  static Future<Database> _database() async {
    final dbPath = await getDatabasesPath();
    final database =
        openDatabase(join(dbPath, _dbName), onCreate: (db, version) {
      // Create the first table
      db.execute(
          'CREATE TABLE tblemployees(Employeeid varchar(255) PRIMARY KEY, FirstName TEXT, LastName TEXT, Department TEXT, Fingerid TEXT)');

      // Create the second table
      db.execute('''
          CREATE TABLE events (
            event_id varchar(255) DEFAULT NULL,
            event_name varchar(255) DEFAULT NULL
          )
          ''');

      // Create the third table
      db.execute('''
          CREATE TABLE scan_logs (
            logs_id varchar(255) DEFAULT NULL,
            event_id varchar(255) DEFAULT NULL,
            Employeeid varchar(255) DEFAULT NULL,
            logs_date varchar(255) DEFAULT NULL,
            logs_time text DEFAULT NULL,
            timestamp varchar(255) DEFAULT NULL
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
    await db.delete(_event); // Delete all rows from the employees table
  }

  static Future<int> getEmployeeCount() async {
    try {
      final db = await _database();
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM tblemployees'));
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

  static Future<void> insertToEvents(
      List<Map<String, dynamic>> activeEvent) async {
    final db = await _database();

    // Generate the values section of the SQL query
    List<String> valueStrings = activeEvent.map((activeEvent) {
      return "('${activeEvent['event_id']}', '${activeEvent['event_name']}')";
    }).toList();

    // Generate the full SQL INSERT query
    String query =
        "INSERT INTO $_event (event_id, event_name) VALUES ${valueStrings.join(',')}";

    await db.rawInsert(query);
  }

  // New method to call all employees from tbl_profile
  static Future<List<Map<String, dynamic>>> callAllEmployees() async {
    final db = await _database();
    var res = await db.rawQuery("SELECT * FROM tblemployees");
    return res;
  }

  // static insert({required Note note}) async {
  //   final db = await _database();
  //   await db.insert(
  //     _tblemployees,
  //     note.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

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
