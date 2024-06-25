import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'attendance';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'attendance.db');

    return await openDatabase(
      databasePath,
      version: 2, 
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            time TEXT,
            isCheckIn INTEGER,
            longitude REAL,
            latitude REAL 
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Perform database migration if upgrading from version 1 to 2
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE $tableName 
            ADD COLUMN longitude REAL
          ''');
          await db.execute('''
            ALTER TABLE $tableName 
            ADD COLUMN latitude REAL
          ''');
        }
      },
    );
  }

  Future<void> insertAttendance(Map<String, dynamic> attendanceData) async {
    final db = await database;
    await db.insert(tableName, attendanceData);
  }

  Future<List<Map<String, dynamic>>> getAttendanceByDate(String date) async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'date = ?',
      whereArgs: [date],
    );
  }
}
