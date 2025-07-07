class ExerciseLog {
  int? id;
  int exerciseId;
  DateTime date;
  int userId;

  ExerciseLog({
    this.id,
    required this.exerciseId,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'date': date.toIso8601String(),
      'user_id': userId,
    };
  }

  factory ExerciseLog.fromMap(Map<String, dynamic> map) {
    return ExerciseLog(
      id: map['id'],
      exerciseId: map['exercise_id'],
      date: DateTime.parse(map['date']),
      userId: map['user_id'],
    );
  }
}
