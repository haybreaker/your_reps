class ExerciseMuscle {
  final int exerciseId;
  final int muscleId;
  final double? intensity;

  ExerciseMuscle({
    required this.exerciseId,
    required this.muscleId,
    this.intensity,
  });

  Map<String, dynamic> toMap() => {
        'exercise_id': exerciseId,
        'muscle_id': muscleId,
        'intensity': intensity,
      };

  static ExerciseMuscle fromMap(Map<String, dynamic> map) => ExerciseMuscle(
        exerciseId: map['exercise_id'],
        muscleId: map['muscle_id'],
        intensity: map['intensity'],
      );
}
