import 'package:flutter/cupertino.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/providers/gym_event_provider.dart';
import 'package:flutter_app/services/network_service.dart';

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

class ScheduleProvider extends ChangeNotifier {
  List<Schedule> schedules = [];

  Future<void> fetchSchedules() async {
    try {
      final response = await NetworkService().get(
        '$apiUrl/schedule/by-user'
      );
      print(response);
    } catch(e) {
      print('Fetch schedules error $e');
    }
  }

  Future<void> createSchedule(List<String> weekdays) async {
    try {
      final response = await NetworkService().post(
          '$apiUrl/schedule',
          body: {"weekdays": weekdays});
      print(response);
    } catch(e) {
      print('Create schedule error $e');
    }
  }
}