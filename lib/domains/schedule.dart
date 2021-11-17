import 'package:flutter_app/domains/gym_event.dart';

class Schedule {
  int id;

  List<GymEvent> events;

  int userId;

  Schedule({
    required this.id,
    required this.events,
    required this.userId,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int,
      events: json['events'].map<GymEvent>((event) => GymEvent.fromJson(event)).toList() as List<GymEvent>,
      userId: json['userId'] as int,
    );
  }
}