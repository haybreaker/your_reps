import 'package:sqlite3/common.dart';

class SqliteSchemaVersions {
  static Future<void> v1ToV2Upgrade(CommonDatabase db) async {
    db.execute('PRAGMA foreign_keys = ON;');

    // --- USERS ---
    db.execute("ALTER TABLE Users ADD COLUMN notes TEXT;");
    db.execute("ALTER TABLE Users ADD COLUMN created_at TEXT;");
    db.execute("ALTER TABLE Users ADD COLUMN updated_at TEXT;");

    // --- MUSCLES ---
    db.execute("ALTER TABLE Muscles ADD COLUMN recovery_index INTEGER;");
    db.execute("ALTER TABLE Muscles ADD COLUMN push_pull TEXT;");
    db.execute("ALTER TABLE Muscles ADD COLUMN created_at TEXT;");
    db.execute("ALTER TABLE Muscles ADD COLUMN updated_at TEXT;");

    // --- EXERCISES ---
    db.execute("ALTER TABLE Exercises ADD COLUMN equipment_type TEXT;");
    db.execute("ALTER TABLE Exercises ADD COLUMN user_id INTEGER;");
    db.execute("ALTER TABLE Exercises ADD COLUMN notes TEXT;");
    db.execute("ALTER TABLE Exercises ADD COLUMN created_at TEXT;");
    db.execute("ALTER TABLE Exercises ADD COLUMN updated_at TEXT;");
    db.execute("""CREATE TABLE IF NOT EXISTS ExerciseMuscles (
      exercise_id INTEGER,
      muscle_id INTEGER,
      intensity REAL,
      PRIMARY KEY (exercise_id, muscle_id),
      FOREIGN KEY (exercise_id) REFERENCES Exercises(id) ON DELETE CASCADE,
      FOREIGN KEY (muscle_id) REFERENCES Muscles(id) ON DELETE CASCADE
    );""");

    // --- EXERCISE LOGS ---
    db.execute("ALTER TABLE ExerciseLogs ADD COLUMN notes TEXT;");
    db.execute("ALTER TABLE ExerciseLogs ADD COLUMN created_at TEXT;");
    db.execute("ALTER TABLE ExerciseLogs ADD COLUMN updated_at TEXT;");

    // --- WORKOUT SETS ---
    db.execute("ALTER TABLE WorkoutSets ADD COLUMN set_type TEXT;");
    db.execute("ALTER TABLE WorkoutSets ADD COLUMN rir INTEGER;");
    db.execute("ALTER TABLE WorkoutSets ADD COLUMN tempo TEXT;");
    db.execute("ALTER TABLE WorkoutSets ADD COLUMN notes TEXT;");
    db.execute("ALTER TABLE WorkoutSets ADD COLUMN created_at TEXT;");
    db.execute("ALTER TABLE WorkoutSets ADD COLUMN updated_at TEXT;");

    // --- REPS ---
    db.execute("ALTER TABLE Reps ADD COLUMN rep_type TEXT;");
    db.execute("ALTER TABLE Reps ADD COLUMN created_at TEXT;");
    db.execute("ALTER TABLE Reps ADD COLUMN updated_at TEXT;");
  }
}
