import 'dart:convert';

class Exercise {
  Exercise({
    required this.id,
    required this.name,
    required this.group,
    required this.description
  });

  final int id;
  final String name;
  final String group;
  final String description;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
      group: json['group'] as String,
      description: json['description'] as String,
    );
  }
}