import './gym_event.dart';
import './user.dart';

class Assignee {
  int id;
  String email;

  Assignee({required this.id, required this.email});

  factory Assignee.fromJson(Map<String, dynamic> json) {
    return Assignee(id: json['id'], email: json['email']);
  }
}

class CoachEvent extends GymEvent {
  Assignee assignee;
  String startDate;
  String endDate;

  CoachEvent({
    id,
    repeat,
    repeatDays,
    smartFiller,
    required this.assignee,
    required this.startDate,
    required this.endDate,
  }) : super(
      id: id, repeat: repeat,
      repeatDays: repeatDays,
      smartFiller: smartFiller
  );

  factory CoachEvent.fromJson(Map<String, dynamic> json) {
    return CoachEvent(
      id: json['id'] as int,
      assignee: Assignee.fromJson(json['assignee']),
      repeat: json['repeat'],
      smartFiller: json['smartFiller'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      repeatDays: List<String>.from(json['repeatDays']),
    );
  }
}