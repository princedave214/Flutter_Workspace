import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('signup.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firstName TEXT,
      lastName TEXT,
      password TEXT,
      mobile TEXT,
      degree TEXT,
      gender TEXT
    )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByMobileAndPassword(
      String mobile, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'mobile = ? AND password = ?',
      whereArgs: [mobile, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
