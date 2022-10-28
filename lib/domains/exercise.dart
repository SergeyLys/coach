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
      name: json['Name'] as String,
      group: json['Group'] as String,
      description: json['Description'] as String,
    );
  }
}