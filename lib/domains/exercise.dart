import 'dart:convert';

class Exercise {
  int id;
  String name;
  Map<String, List<dynamic>> sets;
  String createdAt;
  String updatedAt;
  bool hasChanges = false;

  static Map<String, int> blankSet = {"w": 0, "r": 0};

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
        id: json['id'] as int,
        name: json['name'] as String,
        updatedAt: json['updatedAt'] as String,
        createdAt: json['createdAt'] as String,
        sets: Map<String, List<dynamic>>.from(json['sets'])
    );
  }
}