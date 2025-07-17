class Exercise {
  int? id;
  String name;
  String? equipmentType;
  String? photoLink;
  String? videoLink;
  String? notes;
  int functionIsolationScale;

  Exercise({
    this.id,
    required this.name,
    required this.photoLink,
    required this.videoLink,
    required this.functionIsolationScale,
    this.equipmentType,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'equipment_type': equipmentType,
      'photo_link': photoLink,
      'video_link': videoLink,
      'notes': notes,
      'function_isolation_scale': functionIsolationScale,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      equipmentType: map['equipment_type'],
      photoLink: map['photo_link'],
      videoLink: map['video_link'],
      notes: map['notes'],
      functionIsolationScale: map['function_isolation_scale'],
    );
  }
}
