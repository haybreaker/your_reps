import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'exercise_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE User (
        id INTEGER PRIMARY KEY,
        training_goal TEXT,
        name TEXT,
        age INTEGER,
        weight REAL,
        height REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE Muscles (
        id INTEGER PRIMARY KEY,
        name TEXT,
        location TEXT,
        recovery_index INTEGER,
        push_pull TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE Exercises (
        id INTEGER PRIMARY KEY,
        name TEXT,
        muscle_id INTEGER,
        photo_link TEXT,
        video_link TEXT,
        function_isolation_scale INTEGER,
        FOREIGN KEY (muscle_id) REFERENCES Muscles(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE ExerciseLog (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER,
        date TEXT,
        user_id INTEGER,
        FOREIGN KEY (exercise_id) REFERENCES Exercises(id),
        FOREIGN KEY (user_id) REFERENCES User(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE Sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_log_id INTEGER,
        weight REAL,
        drop_set BOOLEAN,
        super_set BOOLEAN,
        FOREIGN KEY (exercise_log_id) REFERENCES ExerciseLog(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE Reps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        set_id INTEGER,
        count INTEGER,
        effort INTEGER,
        date_time TEXT,
        FOREIGN KEY (set_id) REFERENCES Sets(id)
      )
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data) async {
    final db = await database;
    int id = data['id'];
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> importDb(String importPath) async {
    final dbPath = join(await getDatabasesPath(), 'exercise_app.db');
    final dbFile = File(dbPath);
    final importFile = File(importPath);

    if (await importFile.exists()) {
      if (await dbFile.exists()) {
        await dbFile.delete(); // Replace existing DB
      }
      await importFile.copy(dbPath);
      _database = await _initDatabase(); // Reopen DB connection
    } else {
      throw Exception("Import file does not exist");
    }
  }

  Future<void> exportDB(String exportPath) async {
    final dbPath = join(await getDatabasesPath(), 'exercise_app.db');
    final exportFile = File(exportPath);
    final dbFile = File(dbPath);

    if (await dbFile.exists()) {
      await exportFile.create(recursive: true);
      await dbFile.copy(exportPath);
    } else {
      throw Exception("Database file does not exist");
    }
  }

  // ✅ Delete DB entirely
  Future<void> deleteDB() async {
    final dbPath = join(await getDatabasesPath(), 'exercise_app.db');
    _database = null;
    await deleteDatabase(dbPath);
  }

  // ------ Table-specific CRUD helpers ------

  Future<int> insertUser(Map<String, dynamic> user) async => await insert('User', user);
  Future<List<Map<String, dynamic>>> getUsers() async => await queryAll('User');
  Future<int> updateUser(Map<String, dynamic> user) async => await update('User', user);
  Future<int> deleteUser(int id) async => await delete('User', id);

  Future<int> insertMuscle(Map<String, dynamic> muscle) async => await insert('Muscles', muscle);
  Future<List<Map<String, dynamic>>> getMuscles() async => await queryAll('Muscles');
  Future<int> updateMuscle(Map<String, dynamic> muscle) async => await update('Muscles', muscle);
  Future<int> deleteMuscle(int id) async => await delete('Muscles', id);

  Future<int> insertExercise(Map<String, dynamic> exercise) async => await insert('Exercises', exercise);
  Future<List<Map<String, dynamic>>> getExercises() async => await queryAll('Exercises');
  Future<int> updateExercise(Map<String, dynamic> exercise) async => await update('Exercises', exercise);
  Future<int> deleteExercise(int id) async => await delete('Exercises', id);

  Future<int> insertExerciseLog(Map<String, dynamic> exerciseLog) async => await insert('ExerciseLog', exerciseLog);
  Future<List<Map<String, dynamic>>> getExerciseLogs() async => await queryAll('ExerciseLog');
  Future<int> updateExerciseLog(Map<String, dynamic> exerciseLog) async => await update('ExerciseLog', exerciseLog);
  Future<int> deleteExerciseLog(int id) async => await delete('ExerciseLog', id);

  Future<int> insertSet(Map<String, dynamic> set) async => await insert('Sets', set);
  Future<List<Map<String, dynamic>>> getSets() async => await queryAll('Sets');
  Future<int> updateSet(Map<String, dynamic> set) async => await update('Sets', set);
  Future<int> deleteSet(int id) async => await delete('Sets', id);

  Future<int> insertRep(Map<String, dynamic> rep) async => await insert('Reps', rep);
  Future<List<Map<String, dynamic>>> getReps() async => await queryAll('Reps');
  Future<int> updateRep(Map<String, dynamic> rep) async => await update('Reps', rep);
  Future<int> deleteRep(int id) async => await delete('Reps', id);
}
