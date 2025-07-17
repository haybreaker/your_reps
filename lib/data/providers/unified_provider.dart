import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:your_reps/data/databases/interfaces/database_helper_interface.dart';
import 'package:your_reps/data/objects/exercise.dart';
import 'package:your_reps/data/objects/exercise_log.dart';
import 'package:your_reps/data/objects/exercise_muscle.dart';
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
  List<ExerciseMuscle> _exerciseMuscles = [];
  List<ExerciseLog> _exerciseLogs = [];
  List<WorkoutSet> _sets = [];
  List<Rep> _reps = [];

  // Getters for data lists
  List<User> get users => _users;
  List<Muscle> get muscles => _muscles;
  List<Exercise> get exercises => _exercises;
  List<ExerciseMuscle> get exerciseMuscles => _exerciseMuscles;
  List<ExerciseLog> get exerciseLogs => _exerciseLogs;
  List<WorkoutSet> get sets => _sets;
  List<Rep> get reps => _reps;

  // FETCH IS THE OPERATIONS FOR GETTING DATA FROM THE DB
  Future<void> fetchAll() async {
    await fetchUsers();
    await fetchMuscles();
    await fetchExercises();
    await fetchExerciseMuscles();
    await fetchExerciseLogs();
    await fetchSets();
    await fetchReps();
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    _users = await _dbHelper.getUsers();
    notifyListeners();
  }

  Future<void> fetchMuscles() async {
    _muscles = await _dbHelper.getMuscles();
    notifyListeners();
  }

  Future<void> fetchExercises() async {
    _exercises = await _dbHelper.getExercises();
    notifyListeners();
  }

  Future<void> fetchExerciseMuscles() async {
    _exerciseMuscles = await _dbHelper.getExerciseMuscles();
    notifyListeners();
  }

  Future<void> fetchExerciseLogs() async {
    _exerciseLogs = await _dbHelper.getExerciseLogs();
    notifyListeners();
  }

  Future<void> fetchSets() async {
    _sets = await _dbHelper.getSets();
    notifyListeners();
  }

  Future<void> fetchReps() async {
    _reps = await _dbHelper.getReps();
    notifyListeners();
  }

  // Add methods for all data
  Future<void> addUser(User user) async {
    await _dbHelper.insertUser(user);
    await fetchUsers();
  }

  // GET CALLS (RETURNS DATA)

  List<int> getMuscleIdsForExercise(int exerciseId) {
    return exerciseMuscles.where((em) => em.exerciseId == exerciseId).map((em) => em.muscleId).toList();
  }

  // ALL INSERT OPERATIONS INTO THE DATABASE
  Future<void> addMuscle(Muscle muscle) async {
    await _dbHelper.insertMuscle(muscle);
    await fetchMuscles();
  }

  Future<void> addExercise(Exercise exercise) async {
    await _dbHelper.insertExercise(exercise);
    await fetchExercises();
  }

  Future<void> addExerciseMuscle(ExerciseMuscle entry) async {
    await _dbHelper.insertExerciseMuscle(entry);
    await fetchExerciseMuscles();
  }

  Future<void> addExerciseMuscles(Exercise exercise, List<Muscle> muscles) async {
    for (final muscle in muscles) {
      await _dbHelper.insertExerciseMuscle(ExerciseMuscle(exerciseId: exercise.id!, muscleId: muscle.id!));
    }
    await fetchExerciseMuscles();
  }

  Future<void> addExerciseLog(ExerciseLog exerciseLog) async {
    await _dbHelper.insertExerciseLog(exerciseLog);
    await fetchExerciseLogs();
  }

  Future<void> addSet(WorkoutSet set) async {
    await _dbHelper.insertSet(set);
    await fetchSets();
  }

  Future<void> addRep(Rep rep) async {
    await _dbHelper.insertRep(rep);
    await fetchReps();
  }

  // Update methods for all data
  Future<void> updateUser(User user) async {
    await _dbHelper.updateUser(user);
    await fetchUsers();
  }

  Future<void> updateMuscle(Muscle muscle) async {
    await _dbHelper.updateMuscle(muscle);
    await fetchMuscles();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _dbHelper.updateExercise(exercise);
    await fetchExercises();
  }

  Future<void> updateExerciseMuscles(Exercise exercise, List<Muscle> muscles) async {
    await _dbHelper.deleteAllMusclesForExercise(exercise.id!);
    for (var muscle in muscles) {
      await _dbHelper.insertExerciseMuscle(ExerciseMuscle(exerciseId: exercise.id!, muscleId: muscle.id!));
    }
    await fetchExerciseMuscles();
  }

  Future<void> updateExerciseLog(ExerciseLog exerciseLog) async {
    await _dbHelper.updateExerciseLog(exerciseLog);
    await fetchExerciseLogs();
  }

  Future<void> updateSet(WorkoutSet set) async {
    await _dbHelper.updateSet(set);
    await fetchSets();
  }

  Future<void> updateRep(Rep rep) async {
    await _dbHelper.updateRep(rep);
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

  Future<void> deleteExerciseMuscle(int exerciseId, int muscleId) async {
    await _dbHelper.deleteExerciseMuscle(exerciseId, muscleId);
    await fetchExerciseMuscles();
  }

  Future<void> deleteAllMusclesForExercise(int exerciseId) async {
    await _dbHelper.deleteAllMusclesForExercise(exerciseId);
    await fetchExerciseMuscles();
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
    await _dbHelper.importDb(path);
    await fetchAll();
    notifyListeners();
  }

  Future<void> exportDb(String? path) async {
    await _dbHelper.exportDb(path);
    await fetchAll();
    notifyListeners();
  }

  Future<void> deleteDb() async {
    await _dbHelper.deleteDb();
    await fetchAll();
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

    WorkoutSet set = WorkoutSet(exerciseLogId: exerciseLog.id!, weight: weight, dropSet: false, superSet: false);
    await addSet(set);
    set = sets.last;

    Rep rep = Rep(setId: set.id!, count: count, effort: 10);
    await addRep(rep);
  }
}
