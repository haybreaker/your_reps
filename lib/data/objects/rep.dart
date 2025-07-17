class Rep {
  int? id;
  int setId;
  int count;
  int effort;
  String? repTime;

  Rep({
    this.id,
    required this.setId,
    required this.count,
    required this.effort,
    this.repTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'set_id': setId,
      'count': count,
      'effort': effort,
      'rep_time': repTime,
    };
  }

  factory Rep.fromMap(Map<String, dynamic> map) {
    return Rep(
      id: map['id'],
      setId: map['set_id'],
      count: map['count'],
      effort: map['effort'],
      repTime: map['rep_time'],
    );
  }
}
