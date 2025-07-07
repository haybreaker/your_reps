class Set {
  int? id;
  int exerciseLogId;
  double weight;
  bool dropSet;
  bool superSet;

  Set({
    this.id,
    required this.exerciseLogId,
    required this.weight,
    required this.dropSet,
    required this.superSet,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_log_id': exerciseLogId,
      'weight': weight,
      'drop_set': dropSet ? 1 : 0,
      'super_set': superSet ? 1 : 0,
    };
  }

  factory Set.fromMap(Map<String, dynamic> map) {
    return Set(
      id: map['id'],
      exerciseLogId: map['exercise_log_id'],
      weight: map['weight'],
      dropSet: map['drop_set'] == 1,
      superSet: map['super_set'] == 1,
    );
  }
}
