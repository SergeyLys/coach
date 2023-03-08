import 'dart:convert';

import 'package:flutter_app/domains/muscle_group.dart';

class Exercise {
  Exercise({
    required this.id,
    required this.name,
    required this.group,
    required this.description
  });

  final int id;
  final String name;
  final MuscleGroup group;
  final String description;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      group: MuscleGroup.fromJson(json['group']),
      description: json['description'],
    );
  }
}