import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/employee.dart';
import '../models/events.dart';
import '../models/scan_logs.dart';
import '../models/users.dart';
import '../models/version.dart';

class NoteRepository {
  static const _dbName = 'hris.db';
  static const _tblemployees = 'tblemployees';
  static const _event = 'events';
  static const _tblScanLogs = 'scan_logs';
  static const _usersTable = 'users';
  static const _version = 'version';

  static Future<Database> _database() async {
    final dbPath = await getDatabasesPath();
    final database =
        openDatabase(join(dbPath, _dbName), onCreate: (db, version) {
      // Create the employees table
      db.execute(
          'CREATE TABLE IF NOT EXISTS $_tblemployees(Employeeid TEXT PRIMARY KEY, FirstName TEXT, LastName TEXT, Department TEXT, Fingerid TEXT)');

      // Create the events table
      db.execute('''
          CREATE TABLE IF NOT EXISTS $_event (
            event_id TEXT PRIMARY KEY,
            event_name TEXT
          )
          ''');

      db.execute('''
          CREATE TABLE IF NOT EXISTS $_usersTable (
            user_id TEXT PRIMARY KEY,
            username TEXT,
            password TEXT,
            fullname TEXT
          )
          ''');

      // Create the scan_logs table if needed
      db.execute('''
          CREATE TABLE IF NOT EXISTS $_tblScanLogs (
            logs_id TEXT PRIMARY KEY,
            event_id TEXT,
            Employeeid TEXT,
            logs_date TEXT,
            logs_time TEXT,
            timestamp TEXT,
            remarks TEXT,
            user_id TEXT,
            status_remarks TEXT
          )
          ''');

      db.execute(
          'CREATE TABLE IF NOT EXISTS $_version(version TEXT PRIMARY KEY)');
    }, version: 1);

    return database;
  }

  static Future<void> initDatabase() async {
    await _database();
  }

  static Future<int> getUserCount() async {
    try {
      final db = await _database();
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $_usersTable'));
      // print("user count = " + count.toString());
      return count ?? 0;
    } catch (e) {
      // print('Error getting user count: $e');
      return 0;
    }
  }

  static Future<int> getVersionCount() async {
    try {
      final db = await _database();
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $_version'));
      // print("user count = " + count.toString());
      return count ?? 0;
    } catch (e) {
      // print('Error getting user count: $e');
      return 0;
    }
  }

  static Future<void> deleteUsers() async {
    final db = await _database();
    await db.delete('users');
  }

  static Future<void> deleteAllEmployees() async {
    final db = await _database();
    await db.delete(_tblemployees);
  }

  static Future<List<Map<String, dynamic>>> callAllEvents() async {
    final db = await _database();
    var res = await db.rawQuery("SELECT * FROM $_event");
    return res;
  }

  static Future<List<String>> getDistinctDepartments() async {
    final db = await _database();
    final result =
        await db.rawQuery('SELECT DISTINCT Department FROM $_tblemployees');
    List<String> departments =
        result.map((row) => row['Department'] as String).toList();
    return departments;
  }

  static Future<void> insertScanLog(
      String eventId, String employeeId, String remarks, String user_id) async {
    final db = await _database();

    DateTime now = DateTime.now();
    String formattedDate = DateTime.now().toString().split(' ')[0];
    String formattedTime = "${now.hour}:${now.minute}";

    await db.insert(
      _tblScanLogs,
      {
        'event_id': eventId,
        'Employeeid': employeeId,
        'logs_date': formattedDate,
        'logs_time': formattedTime,
        'timestamp': now.toString(),
        'remarks': remarks,
        'user_id': user_id,
        'status_remarks': "active"
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteArchiveLogs(String? dateScanned) async {
    final db = await _database();
    // print("DateScanned:  $dateScanned");
    await db.rawQuery(
      'delete FROM scan_logs WHERE logs_date = ? AND status_remarks = "uploaded"',
      [dateScanned],
    );

    // DateTime now = DateTime.now();
    // String formattedDate = DateTime.now().toString().split(' ')[0];
    // String formattedTime = "${now.hour}:${now.minute}";

    // await db.insert(
    //   _tblScanLogs,
    //   {
    //     'event_id': eventId,
    //     'Employeeid': employeeId,
    //     'logs_date': formattedDate,
    //     'logs_time': formattedTime,
    //     'timestamp': now.toString(),
    //     'remarks': remarks,
    //     'user_id': user_id,
    //     'status_remarks': "active"
    //   },
    //   conflictAlgorithm: ConflictAlgorithm.replace,
    // );
  }

  static Future<List<Employee>> getEmployeesByDepartment(
      String department) async {
    final db = await _database();
    final List<Map<String, dynamic>> maps = await db.query(
      _tblemployees,
      where: "Department = ?",
      whereArgs: [department],
    );
    return List.generate(maps.length, (i) {
      return Employee(
        id: maps[i]['Employeeid'],
        firstName: maps[i]['FirstName'],
        lastName: maps[i]['LastName'],
        department: maps[i]['Department'],
        fingerId: maps[i]['Fingerid'],
      );
    });
  }

  static Future<List<Map<String, dynamic>>> getAllScanLogs() async {
    final db = await _database();
    var res = await db.rawQuery('''
      SELECT scan_logs.Employeeid, e.FirstName || ' ' || e.LastName AS fullname, 
      u.fullname as scanner_fullname, 
      e.Department,
      events.event_name, 
      scan_logs.logs_date AS date,
      scan_logs.logs_time as time,
      scan_logs.remarks
FROM scan_logs
LEFT JOIN tblemployees e ON e.Employeeid = scan_logs.Employeeid
LEFT JOIN events ON events.event_id = scan_logs.event_id
LEFT JOIN users u on u.user_id = scan_logs.user_id
where status_remarks = 'active'
;
    ''');
    return res;
  }

  static Future<List<Map<String, dynamic>>> getHistoryScanLogs() async {
    final db = await _database();
    var res = await db.rawQuery('''
          SELECT scan_logs.Employeeid, e.FirstName || ' ' || e.LastName AS fullname, 
          u.fullname as scanner_fullname, 
          e.Department,
          events.event_name, 
          scan_logs.logs_date AS date,
          scan_logs.logs_time as time,
          scan_logs.remarks
    FROM scan_logs
    LEFT JOIN tblemployees e ON e.Employeeid = scan_logs.Employeeid
    LEFT JOIN events ON events.event_id = scan_logs.event_id
    LEFT JOIN users u on u.user_id = scan_logs.user_id
    where status_remarks = 'uploaded'
    ;
    ''');
    return res;
  }

  static Future<void> archiveScanLogs() async {
    final db = await _database();
    await db.rawQuery('''
  UPDATE scan_logs set status_remarks = 'uploaded' where status_remarks = 'active';
    ''');
  }

  static Future<bool> checkScanLog(
      String employeeId, String eventId, String remarks) async {
    try {
      // DateTime now = DateTime.now();
      String formattedDate = DateTime.now().toString().split(' ')[0];
      final db = await _database();
      final List<Map<String, dynamic>> logs = await db.rawQuery(
        'SELECT * FROM scan_logs '
        'WHERE Employeeid = ? AND logs_date = ? AND remarks = ?',
        [employeeId, formattedDate, remarks],
      );

      return logs.isNotEmpty; // Return true if logs are found, false otherwise
    } catch (e) {
      // print('Error checking scan logs: $e');
      return false; // Return false in case of an error
    }
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
      // print('Error getting employee count: $e');
      return 0;
    }
  }

  static Future<int> getScanLogsCount() async {
    try {
      final db = await _database();
      final count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM $_tblScanLogs where status_remarks = "active"'));
      return count ?? 0;
    } catch (e) {
      // print('Error getting scan count: $e');
      return 0;
    }
  }

  static Future<bool> undoScanLog(
      String employeeId, String eventId, String Remarks) async {
    try {
      String formattedDate = DateTime.now().toString().split(' ')[0];
      final db = await _database();
      // Delete the scan log based on employeeId and eventId
      int rowsAffected = await db.delete(
        _tblScanLogs,
        where: 'Employeeid = ? AND logs_date = ? and remarks = ?',
        whereArgs: [employeeId, formattedDate, Remarks],
      );

      // Check if any rows were affected (scan log deleted)
      return rowsAffected > 0;
    } catch (e) {
      // print('Error undoing scan log: $e');
      return false; // Return false in case of an error
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
      // print('Error checking employee existence: $e');
      return false;
    }
  }

  static Future<List<Employee>> searchEmployees(String searchKeyword) async {
    try {
      final db = await _database();
      final List<Map<String, dynamic>> employeeData = await db.rawQuery(
          "SELECT * FROM $_tblemployees WHERE Fingerid = ? OR FirstName LIKE ? OR LastName LIKE ? or ((FirstName || ' ' || LastName) LIKE ? or (LastName || ' ' || FirstName) LIKE ?)",
          [
            searchKeyword,
            '%$searchKeyword%',
            '%$searchKeyword%',
            '%$searchKeyword%',
            '%$searchKeyword%'
          ]);

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
      // print('Error searching employees: $e');
      return []; // Return an empty list if there's an error
    }
  }


    static Future<void> insertIntoVersion(String version) async {
    final db = await _database();
    String query =
        "INSERT INTO $_version (version) VALUES $version";
    await db.rawInsert(query);
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

  static Future<void> insertUser(User user) async {
    final db = await _database();
    await db.insert(
      _usersTable,
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<User>> getUsers() async {
    final db = await _database();
    final List<Map<String, dynamic>> userMaps = await db.query('users');
    return List.generate(userMaps.length, (i) {
      return User(
        userId: userMaps[i]['user_id'],
        fullname: userMaps[i]['fullname'],
        username: userMaps[i]['username'],
        password: "",
      );
    });
  }

  static Future<List<Version>> getVersion() async {
    final db = await _database();
    final List<Map<String, dynamic>> versionMaps = await db.query('version');
    return List.generate(versionMaps.length, (i) {

      return Version(version: versionMaps[i]['version'])

    
    });
  }

  static Future<bool> isUserExist(String userId) async {
    final db = await _database();
    final List<Map<String, dynamic>> result = await db.query(
      _usersTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty;
  }

  static Future<void> deleteAllUsers() async {
    final db = await _database();
    await db.delete(_usersTable);
  }

  static Future<void> deleteScanLogs() async {
    final db = await _database();
    await db.delete(_tblScanLogs);
  }
}
