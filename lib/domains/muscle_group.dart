class MuscleGroup {
  MuscleGroup({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory MuscleGroup.fromJson(Map<String, dynamic> json) {
    return MuscleGroup(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}