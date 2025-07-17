import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqlite3/common.dart';
import 'package:universal_html/html.dart' as html;
import 'package:your_reps/data/databases/interfaces/database_helper_interface.dart';
import 'package:your_reps/data/objects/exercise.dart';
import 'package:your_reps/data/objects/exercise_log.dart';
import 'package:your_reps/data/objects/exercise_muscle.dart';
import 'package:your_reps/data/objects/muscle.dart';
import 'package:your_reps/data/objects/rep.dart';
import 'package:your_reps/data/objects/set.dart';
import 'package:your_reps/data/objects/user.dart';

// This conditionally imports the correct connection logic for the platform.
import 'native_stubs/connection_stub.dart'
    if (dart.library.io) 'native_stubs/connection_native.dart'
    if (dart.library.html) 'native_stubs/connection_web.dart';

class SqliteDatabaseHelper implements DatabaseHelperInterface {
  late CommonDatabase _db;
  bool _isDbInitialized = false;

  static const String _dbName = 'workout_db.db';

  // --- Table Creation ---
  static const String _createUserTable = '''
    CREATE TABLE IF NOT EXISTS Users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      training_goal TEXT,
      name TEXT,
      age INTEGER,
      weight REAL,
      height REAL,
      notes TEXT,
      created_at TEXT,
      updated_at TEXT
    );
  ''';

  static const String _createMusclesTable = '''
    CREATE TABLE IF NOT EXISTS Muscles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      location TEXT,
      recovery_index INTEGER,
      push_pull TEXT,
      created_at TEXT,
      updated_at TEXT
    );
  ''';

  static const String _createExercisesTable = '''
    CREATE TABLE IF NOT EXISTS Exercises (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      equipment_type TEXT,
      photo_link TEXT,
      video_link TEXT,
      function_isolation_scale INTEGER,
      user_id INTEGER,
      notes TEXT,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE SET NULL
    );
  ''';

  static const String _createExerciseMusclesTable = '''
    CREATE TABLE IF NOT EXISTS ExerciseMuscles (
      exercise_id INTEGER,
      muscle_id INTEGER,
      intensity REAL,
      created_at TEXT,
      updated_at TEXT,
      PRIMARY KEY (exercise_id, muscle_id),
      FOREIGN KEY (exercise_id) REFERENCES Exercises (id) ON DELETE CASCADE,
      FOREIGN KEY (muscle_id) REFERENCES Muscles (id) ON DELETE CASCADE
    );
  ''';

  static const String _createExerciseLogTable = '''
    CREATE TABLE IF NOT EXISTS ExerciseLogs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      exercise_id INTEGER,
      date TEXT,
      user_id INTEGER,
      notes TEXT,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY (exercise_id) REFERENCES Exercises (id) ON DELETE CASCADE,
      FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE
    );
  ''';

  static const String _createSetsTable = '''
    CREATE TABLE IF NOT EXISTS WorkoutSets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      exercise_log_id INTEGER,
      weight REAL,
      set_type TEXT,
      rir INTEGER,
      tempo TEXT,
      drop_set INTEGER,
      super_set INTEGER,
      notes TEXT,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY (exercise_log_id) REFERENCES ExerciseLogs (id) ON DELETE CASCADE
    );
  ''';

  static const String _createRepsTable = '''
    CREATE TABLE IF NOT EXISTS Reps (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      set_id INTEGER,
      count INTEGER,
      effort INTEGER,
      rep_time TEXT,
      rep_type TEXT,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY (set_id) REFERENCES WorkoutSets (id) ON DELETE CASCADE
    );
  ''';

  @override
  Future<void> init() async {
    if (_isDbInitialized) return;

    _db = await openConnection();

    // Enable foreign keys and create tables
    _db.execute('PRAGMA foreign_keys = ON;');
    _db.execute(_createUserTable);
    _db.execute(_createMusclesTable);
    _db.execute(_createExercisesTable);
    _db.execute(_createExerciseMusclesTable);
    _db.execute(_createExerciseLogTable);
    _db.execute(_createSetsTable);
    _db.execute(_createRepsTable);

    _isDbInitialized = true;
  }

  // --- Database Management ---

  @override
  Future<void> importDb(PlatformFile file) async {
    final fileBytes = file.bytes;
    if (fileBytes == null) {
      throw Exception("File bytes are null, cannot import.");
    }

    if (kIsWeb) {
      writeDbBytes(_dbName, fileBytes);
      init();
    } else {
      final dbPath = join((await getApplicationDocumentsDirectory()).path, _dbName);

      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        await dbFile.delete(); // Remove old DB
      }
      await dbFile.writeAsBytes(fileBytes);
      init();
    }
  }

  @override
  Future<void> exportDb(String? exportPath) async {
    final fileName = 'your_reps_export_${DateTime.now().toIso8601String()}.db';

    if (kIsWeb) {
      final bytes = await readDbBytes(_dbName);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none'
        ..click();

      html.Url.revokeObjectUrl(url);
    } else {
      // Native flow
      if (exportPath == null) {
        throw Exception("Export path is required on native platforms.");
      }

      final dbPath = join((await getApplicationDocumentsDirectory()).path, _dbName);
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw Exception("Database file does not exist");
      }

      final exportFile = File(exportPath);
      await exportFile.create(recursive: true);
      await dbFile.copy(exportPath);
    }
  }

  @override
  Future<void> deleteDb() async {
    if (!_isDbInitialized) return;

    await _closeExistingConnection();

    if (kIsWeb) {
      deleteDbBytes(_dbName);
    } else {
      final dbPath = join((await getApplicationDocumentsDirectory()).path, _dbName);
      final file = File(dbPath);
      if (await file.exists()) await file.delete();
    }

    // Reinitialize the database after deletion to ensure it's ready for use
    await init();
  }

  // --- Helper Methods ---

  Future<void> _closeExistingConnection() async {
    if (_isDbInitialized) {
      _db.dispose();
      _isDbInitialized = false;
    }
  }

  // --- Dynamic CRUD Operations ---

  Future<int> _insert(String table, Map<String, dynamic> data) async {
    data['created_at'] = DateTime.now().toIso8601String();
    final keys = data.keys.toList();
    final values = data.values.toList();
    final placeholders = List.filled(keys.length, '?').join(',');
    final sql = 'INSERT INTO $table (${keys.join(',')}) VALUES ($placeholders)';

    final stmt = _db.prepare(sql);
    stmt.execute(values);
    final id = _db.lastInsertRowId;
    stmt.dispose();
    return id;
  }

  Future<List<Map<String, dynamic>>> _queryAll(String table) async {
    final ResultSet resultSet = _db.select('SELECT * FROM $table');
    return resultSet.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<int> _update(String table, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    final id = data['id'];
    final keys = data.keys.where((key) => key != 'id').toList();
    final values = [...keys.map((key) => data[key]), id];
    final setClause = keys.map((key) => '$key = ?').join(', ');
    final sql = 'UPDATE $table SET $setClause WHERE id = ?';

    final stmt = _db.prepare(sql);
    stmt.execute(values);
    final updatedRows = _db.updatedRows;
    stmt.dispose();
    return updatedRows;
  }

  Future<int> _delete(String table, int id) async {
    final stmt = _db.prepare('DELETE FROM $table WHERE id = ?');
    stmt.execute([id]);
    final deletedRows = _db.updatedRows;
    stmt.dispose();
    return deletedRows;
  }

  // --- Typed CRUD Operations ---

  // USER
  @override
  Future<int> insertUser(User user) async => await _insert('Users', user.toMap());
  @override
  Future<List<User>> getUsers() async => (await _queryAll('Users')).map((map) => User.fromMap(map)).toList();
  @override
  Future<int> updateUser(User user) async => await _update('Users', user.toMap());
  @override
  Future<int> deleteUser(int id) async => await _delete('Users', id);

  // MUSCLE
  @override
  Future<int> insertMuscle(Muscle muscle) async => await _insert('Muscles', muscle.toMap());
  @override
  Future<List<Muscle>> getMuscles() async => (await _queryAll('Muscles')).map((map) => Muscle.fromMap(map)).toList();
  @override
  Future<int> updateMuscle(Muscle muscle) async => await _update('Muscles', muscle.toMap());
  @override
  Future<int> deleteMuscle(int id) async => await _delete('Muscles', id);

  // EXERCISE
  @override
  Future<int> insertExercise(Exercise exercise) async => await _insert('Exercises', exercise.toMap());
  @override
  Future<List<Exercise>> getExercises() async => (await _queryAll('Exercises')).map((map) => Exercise.fromMap(map)).toList();
  @override
  Future<int> updateExercise(Exercise exercise) async => await _update('Exercises', exercise.toMap());
  @override
  Future<int> deleteExercise(int id) async => await _delete('Exercises', id);

  // EXERCISE MUSCLE MANY TO MANY CONNECTIONS
  @override
  Future<int> insertExerciseMuscle(ExerciseMuscle entry) async => await _insert('ExerciseMuscles', entry.toMap());
  @override
  Future<List<ExerciseMuscle>> getExerciseMuscles() async =>
      (await _queryAll('ExerciseMuscles')).map((map) => ExerciseMuscle.fromMap(map)).toList();
  @override
  Future<int> deleteExerciseMuscle(int exerciseId, int muscleId) async {
    final stmt = _db.prepare('DELETE FROM ExerciseMuscles WHERE exercise_id = ? AND muscle_id = ?');
    stmt.execute([exerciseId, muscleId]);
    final deletedRows = _db.updatedRows;
    stmt.dispose();
    return deletedRows;
  }

  @override
  Future<List<ExerciseMuscle>> getMusclesForExercise(int exerciseId) async {
    final result = _db.select('SELECT * FROM ExerciseMuscles WHERE exercise_id = ?', [exerciseId]);
    return result.map((map) => ExerciseMuscle.fromMap(map)).toList();
  }

  @override
  Future<int> deleteAllMusclesForExercise(int exerciseId) async {
    final stmt = _db.prepare('DELETE FROM ExerciseMuscles WHERE exercise_id = ?');
    stmt.execute([exerciseId]);
    final deletedRows = _db.updatedRows;
    stmt.dispose();
    return deletedRows;
  }

  // EXERCISE LOG
  @override
  Future<int> insertExerciseLog(ExerciseLog log) async => await _insert('ExerciseLogs', log.toMap());
  @override
  Future<List<ExerciseLog>> getExerciseLogs() async =>
      (await _queryAll('ExerciseLogs')).map((map) => ExerciseLog.fromMap(map)).toList();
  @override
  Future<int> updateExerciseLog(ExerciseLog log) async => await _update('ExerciseLogs', log.toMap());
  @override
  Future<int> deleteExerciseLog(int id) async => await _delete('ExerciseLogs', id);

  // SET
  @override
  Future<int> insertSet(WorkoutSet set) async => await _insert('WorkoutSets', set.toMap());
  @override
  Future<List<WorkoutSet>> getSets() async =>
      (await _queryAll('WorkoutSets')).map((map) => WorkoutSet.fromMap(map)).toList();
  @override
  Future<int> updateSet(WorkoutSet set) async => await _update('WorkoutSets', set.toMap());
  @override
  Future<int> deleteSet(int id) async => await _delete('WorkoutSets', id);

  // REP
  @override
  Future<int> insertRep(Rep rep) async => await _insert('Reps', rep.toMap());
  @override
  Future<List<Rep>> getReps() async => (await _queryAll('Reps')).map((map) => Rep.fromMap(map)).toList();
  @override
  Future<int> updateRep(Rep rep) async => await _update('Reps', rep.toMap());
  @override
  Future<int> deleteRep(int id) async => await _delete('Reps', id);
}
