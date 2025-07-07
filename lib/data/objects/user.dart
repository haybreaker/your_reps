class User {
  int? id;
  String trainingGoal;
  String name;
  int age;
  double weight;
  double height;

  User({
    this.id,
    required this.trainingGoal,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'training_goal': trainingGoal,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      trainingGoal: map['training_goal'],
      name: map['name'],
      age: map['age'],
      weight: map['weight'],
      height: map['height'],
    );
  }
}
