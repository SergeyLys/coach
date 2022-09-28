import 'package:flutter_app/domains/gym_event.dart';

class Schedule {
  int id;

  int userId;

  String name;

  Schedule({
    required this.id,
    required this.userId,
    required this.name,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String,
    );
  }
}