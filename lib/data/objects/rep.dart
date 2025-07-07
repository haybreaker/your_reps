class Reps {
  int? id;
  int setId;
  int count;
  int effort;

  Reps({
    this.id,
    required this.setId,
    required this.count,
    required this.effort,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'set_id': setId,
      'count': count,
      'effort': effort,
    };
  }

  factory Reps.fromMap(Map<String, dynamic> map) {
    return Reps(
      id: map['id'],
      setId: map['set_id'],
      count: map['count'],
      effort: map['effort'],
    );
  }
}
