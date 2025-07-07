import 'dart:convert';

class Exercise {
  int? id;
  String name;
  List<int> muscleId;
  String? photoLink;
  String? videoLink;
  int functionIsolationScale;

  Exercise({
    this.id,
    required this.name,
    required this.muscleId,
    required this.photoLink,
    required this.videoLink,
    required this.functionIsolationScale,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscle_id': jsonEncode(muscleId),
      'photo_link': photoLink,
      'video_link': videoLink,
      'function_isolation_scale': functionIsolationScale,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      muscleId: List<int>.from(jsonDecode(map['muscle_id'])),
      photoLink: map['photo_link'],
      videoLink: map['video_link'],
      functionIsolationScale: map['function_isolation_scale'],
    );
  }
}
