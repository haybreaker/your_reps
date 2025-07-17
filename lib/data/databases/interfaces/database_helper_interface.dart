import 'package:file_picker/file_picker.dart';
import 'package:your_reps/data/objects/exercise.dart';
import 'package:your_reps/data/objects/exercise_log.dart';
import 'package:your_reps/data/objects/exercise_muscle.dart';
import 'package:your_reps/data/objects/muscle.dart';
import 'package:your_reps/data/objects/rep.dart';
import 'package:your_reps/data/objects/set.dart';
import 'package:your_reps/data/objects/user.dart';

abstract class DatabaseHelperInterface {
  Future<void> init();

  Future<void> importDb(PlatformFile file);
  Future<void> exportDb(String? exportPath);
  Future<void> deleteDb();

  // CRUD helpers
  Future<int> insertUser(User user);
  Future<List<User>> getUsers();
  Future<int> updateUser(User user);
  Future<int> deleteUser(int id);

  Future<int> insertMuscle(Muscle muscle);
  Future<List<Muscle>> getMuscles();
  Future<int> updateMuscle(Muscle muscle);
  Future<int> deleteMuscle(int id);

  Future<int> insertExercise(Exercise exercise);
  Future<List<Exercise>> getExercises();
  Future<int> updateExercise(Exercise exercise);
  Future<int> deleteExercise(int id);

  Future<int> insertExerciseMuscle(ExerciseMuscle entry);
  Future<List<ExerciseMuscle>> getExerciseMuscles();
  Future<int> deleteExerciseMuscle(int exerciseId, int muscleId);
  Future<List<ExerciseMuscle>> getMusclesForExercise(int exerciseId);
  Future<int> deleteAllMusclesForExercise(int exerciseId);

  Future<int> insertExerciseLog(ExerciseLog exerciseLog);
  Future<List<ExerciseLog>> getExerciseLogs();
  Future<int> updateExerciseLog(ExerciseLog exerciseLog);
  Future<int> deleteExerciseLog(int id);

  Future<int> insertSet(WorkoutSet set);
  Future<List<WorkoutSet>> getSets();
  Future<int> updateSet(WorkoutSet set);
  Future<int> deleteSet(int id);

  Future<int> insertRep(Rep reps);
  Future<List<Rep>> getReps();
  Future<int> updateRep(Rep reps);
  Future<int> deleteRep(int id);
}
