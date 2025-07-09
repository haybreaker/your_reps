import 'dart:io';
import 'dart:io' as io;
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:universal_html/html.dart' as html;
import 'package:your_reps/data/databases/sqlite3/interfaces/database_helper_interface.dart';

class SqliteDatabaseHelper extends DatabaseHelperInterface {
  static final SqliteDatabaseHelper _instance = SqliteDatabaseHelper._internal();
  factory SqliteDatabaseHelper() => _instance;
  SqliteDatabaseHelper._internal();

  static Database? _database;

  @override
  Future<void> init() => _initDatabase();

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

  @override
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  @override
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  @override
  Future<int> update(String table, Map<String, dynamic> data) async {
    final db = await database;
    int id = data['id'];
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> importDb(PlatformFile file) async {
    final fileBytes = file.bytes;

    if (fileBytes == null || fileBytes.isEmpty) {
      throw Exception("Import file is empty or null");
    }

    if (kIsWeb) {
      // WEB: Clear the existing IndexedDB (delete DB)
      final factory = databaseFactoryFfiWeb;
      await factory.deleteDatabase('exercise_app.db');

      // WEB: Re-create from bytes (requires custom support, see note below)
      await factory.writeDatabaseBytes(
        'exercise_app.db',
        fileBytes,
      );

      _database = await openDatabase('exercise_app.db');
    } else {
      // DESKTOP / MOBILE
      final dbPath = join(await getDatabasesPath(), 'exercise_app.db');
      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        await dbFile.delete(); // Remove old DB
      }
      await dbFile.writeAsBytes(fileBytes);
      _database = await openDatabase(dbPath);
    }
  }

  @override
  Future<void> exportDb(String? exportPath) async {
    final dbPath = join(await getDatabasesPath(), 'exercise_app.db');

    if (kIsWeb) {
      // ✅ WEB: Trigger download using browser
      final dbBytes = await _getDbBytes(dbPath);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final exportFileName = "your_reps_export_$timestamp.db";

      final blob = html.Blob([dbBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", exportFileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // ✅ DESKTOP / MOBILE
      if (exportPath == null) {
        throw Exception("Export path is null");
      }

      final dbFile = io.File(dbPath);
      final exportFile = io.File(exportPath);

      if (await dbFile.exists()) {
        await exportFile.create(recursive: true);
        await dbFile.copy(exportPath);
      } else {
        throw Exception("Database file does not exist");
      }
    }
  }

  Future<Uint8List> _getDbBytes(String dbPath) async {
    final file = XFile(dbPath);
    return await file.readAsBytes();
  }

  // ✅ Delete DB entirely
  @override
  Future<void> deleteDb() async {
    final dbPath = join(await getDatabasesPath(), 'exercise_app.db');
    _database = null;
    await deleteDatabase(dbPath);
  }

  // ------ Table-specific CRUD helpers ------

  @override
  Future<int> insertUser(Map<String, dynamic> user) async => await insert('User', user);
  @override
  Future<List<Map<String, dynamic>>> getUsers() async => await queryAll('User');
  @override
  Future<int> updateUser(Map<String, dynamic> user) async => await update('User', user);
  @override
  Future<int> deleteUser(int id) async => await delete('User', id);

  @override
  Future<int> insertMuscle(Map<String, dynamic> muscle) async => await insert('Muscles', muscle);
  @override
  Future<List<Map<String, dynamic>>> getMuscles() async => await queryAll('Muscles');
  @override
  Future<int> updateMuscle(Map<String, dynamic> muscle) async => await update('Muscles', muscle);
  @override
  Future<int> deleteMuscle(int id) async => await delete('Muscles', id);

  @override
  Future<int> insertExercise(Map<String, dynamic> exercise) async => await insert('Exercises', exercise);
  @override
  Future<List<Map<String, dynamic>>> getExercises() async => await queryAll('Exercises');
  @override
  Future<int> updateExercise(Map<String, dynamic> exercise) async => await update('Exercises', exercise);
  @override
  Future<int> deleteExercise(int id) async => await delete('Exercises', id);

  @override
  Future<int> insertExerciseLog(Map<String, dynamic> exerciseLog) async => await insert('ExerciseLog', exerciseLog);
  @override
  Future<List<Map<String, dynamic>>> getExerciseLogs() async => await queryAll('ExerciseLog');
  @override
  Future<int> updateExerciseLog(Map<String, dynamic> exerciseLog) async => await update('ExerciseLog', exerciseLog);
  @override
  Future<int> deleteExerciseLog(int id) async => await delete('ExerciseLog', id);

  @override
  Future<int> insertSet(Map<String, dynamic> set) async => await insert('Sets', set);
  @override
  Future<List<Map<String, dynamic>>> getSets() async => await queryAll('Sets');
  @override
  Future<int> updateSet(Map<String, dynamic> set) async => await update('Sets', set);
  @override
  Future<int> deleteSet(int id) async => await delete('Sets', id);

  @override
  Future<int> insertRep(Map<String, dynamic> rep) async => await insert('Reps', rep);
  @override
  Future<List<Map<String, dynamic>>> getReps() async => await queryAll('Reps');
  @override
  Future<int> updateRep(Map<String, dynamic> rep) async => await update('Reps', rep);
  @override
  Future<int> deleteRep(int id) async => await delete('Reps', id);
}
