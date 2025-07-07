class Muscle {
  int? id;
  String name;
  String location;
  int recoveryIndex;
  String pushPull;

  Muscle({
    this.id,
    required this.name,
    required this.location,
    required this.recoveryIndex,
    required this.pushPull,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'recovery_index': recoveryIndex,
      'push_pull': pushPull,
    };
  }

  factory Muscle.fromMap(Map<String, dynamic> map) {
    return Muscle(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      recoveryIndex: map['recovery_index'],
      pushPull: map['push_pull'],
    );
  }
}
