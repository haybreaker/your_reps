import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:your_reps/data/databases/sqlite3/interfaces/database_helper_interface.dart';
import 'package:your_reps/data/objects/exercise.dart';
import 'package:your_reps/data/objects/exercise_log.dart';
import 'package:your_reps/data/objects/muscle.dart';
import 'package:your_reps/data/objects/rep.dart';
import 'package:your_reps/data/objects/user.dart';
import 'package:your_reps/data/objects/set.dart';

class UnifiedProvider with ChangeNotifier {
  final DatabaseHelperInterface _dbHelper;
  UnifiedProvider({required dbHelper}) : _dbHelper = dbHelper;
  // All data lists
  List<User> _users = [];
  List<Muscle> _muscles = [];
  List<Exercise> _exercises = [];
  List<ExerciseLog> _exerciseLogs = [];
  List<Set> _sets = [];
  List<Reps> _reps = [];

  // Getters for data lists
  List<User> get users => _users;
  List<Muscle> get muscles => _muscles;
  List<Exercise> get exercises => _exercises;
  List<ExerciseLog> get exerciseLogs => _exerciseLogs;
  List<Set> get sets => _sets;
  List<Reps> get reps => _reps;

  // Fetch methods for all data
  Future<void> fetchUsers() async {
    _users = (await _dbHelper.getUsers()).map((m) => User.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> fetchMuscles() async {
    _muscles = (await _dbHelper.getMuscles()).map((m) => Muscle.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> fetchExercises() async {
    _exercises = (await _dbHelper.getExercises()).map((m) => Exercise.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> fetchExerciseLogs() async {
    _exerciseLogs = (await _dbHelper.getExerciseLogs()).map((m) => ExerciseLog.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> fetchSets() async {
    _sets = (await _dbHelper.getSets()).map((m) => Set.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> fetchReps() async {
    _reps = (await _dbHelper.getReps()).map((m) => Reps.fromMap(m)).toList();
    notifyListeners();
  }

  // Add methods for all data
  Future<void> addUser(User user) async {
    await _dbHelper.insertUser(user.toMap());
    await fetchUsers();
  }

  Future<void> addMuscle(Muscle muscle) async {
    await _dbHelper.insertMuscle(muscle.toMap());
    await fetchMuscles();
  }

  Future<void> addExercise(Exercise exercise) async {
    await _dbHelper.insertExercise(exercise.toMap());
    await fetchExercises();
  }

  Future<void> addExerciseLog(ExerciseLog exerciseLog) async {
    await _dbHelper.insertExerciseLog(exerciseLog.toMap());
    await fetchExerciseLogs();
  }

  Future<void> addSet(Set set) async {
    await _dbHelper.insertSet(set.toMap());
    await fetchSets();
  }

  Future<void> addReps(Reps rep) async {
    await _dbHelper.insertRep(rep.toMap());
    await fetchReps();
  }

  // Update methods for all data
  Future<void> updateUser(User user) async {
    await _dbHelper.updateUser(user.toMap());
    await fetchUsers();
  }

  Future<void> updateMuscle(Muscle muscle) async {
    await _dbHelper.updateMuscle(muscle.toMap());
    await fetchMuscles();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _dbHelper.updateExercise(exercise.toMap());
    await fetchExercises();
  }

  Future<void> updateExerciseLog(ExerciseLog exerciseLog) async {
    await _dbHelper.updateExerciseLog(exerciseLog.toMap());
    await fetchExerciseLogs();
  }

  Future<void> updateSet(Set set) async {
    await _dbHelper.updateSet(set.toMap());
    await fetchSets();
  }

  Future<void> updateRep(Reps rep) async {
    await _dbHelper.updateRep(rep.toMap());
    await fetchReps();
  }

  // Delete methods for all data
  Future<void> deleteUser(int id) async {
    await _dbHelper.deleteUser(id);
    await fetchUsers();
  }

  Future<void> deleteMuscle(int id) async {
    await _dbHelper.deleteMuscle(id);
    await fetchMuscles();
  }

  Future<void> deleteExercise(int id) async {
    await _dbHelper.deleteExercise(id);
    await fetchExercises();
  }

  Future<void> deleteExerciseLog(int id) async {
    await _dbHelper.deleteExerciseLog(id);
    await fetchExerciseLogs();
  }

  Future<void> deleteSet(int id) async {
    await _dbHelper.deleteSet(id);
    await fetchSets();
  }

  Future<void> deleteRep(int id) async {
    await _dbHelper.deleteRep(id);
    await fetchReps();
  }

  // Full Database Modifiers
  Future<void> importDb(PlatformFile path) async {
    _dbHelper.importDb(path);
    notifyListeners();
  }

  Future<void> exportDb(String? path) async {
    _dbHelper.exportDb(path);
    notifyListeners();
  }

  Future<void> deleteDb() async {
    _dbHelper.deleteDb();
    notifyListeners();
  }

  // Business Logic For Reads / Writes of Complex Models

  Future<void> recordSet(Exercise exercise, double weight, int count) async {
    // Get todays exercise log
    var exerciseLog = exerciseLogs.firstWhereOrNull(
        (exerciseLog) => DateUtils.isSameDay(exerciseLog.date, DateTime.now()) && exerciseLog.exerciseId == exercise.id);
    if (exerciseLog == null) {
      await addExerciseLog(ExerciseLog(date: DateTime.now(), exerciseId: exercise.id!, userId: 1));
      exerciseLog = exerciseLogs.last;
    }

    Set set = Set(exerciseLogId: exerciseLog.id!, weight: weight, dropSet: false, superSet: false);
    await addSet(set);
    set = sets.last;

    Reps reps = Reps(setId: set.id!, count: count, effort: 10);
    await addReps(reps);
  }
}
