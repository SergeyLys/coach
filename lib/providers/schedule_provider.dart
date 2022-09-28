import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/services/network_service.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/domains/gym_event.dart';
import 'package:flutter_app/domains/schedule.dart';

class ScheduleProvider extends ChangeNotifier {
  Schedule? _schedule;
  List<Schedule> _schedules = [];

  Schedule? get schedule => _schedule;

  List<Schedule> get schedules => _schedules;

  List<Schedule> parseEntities(List<dynamic> responseBody) => responseBody.map<Schedule>((json) => Schedule.fromJson(json)).toList();

  Future<void> fetchSchedules() async {
    try {
      final response = await NetworkService().get(
        '$apiUrl/schedule/by-user'
      );

      final result = parseEntities(response);

      _schedules = result;
      notifyListeners();
    } catch(e) {
      print('fetchSchedules error $e');
    }
  }

  Future<void> createSchedule(String name, List<String> weekdays) async {
    try {
      final response = await NetworkService().post(
          '$apiUrl/schedule',
          body: {"weekdays": weekdays, "name": name});

      final result = Schedule.fromJson(response);

      _schedules.add(result);
      notifyListeners();
    } catch(e) {
      print('createSchedule error $e');
    }
  }

  Future<void> updateSchedule(int scheduleId, String name) async {
    try {
      final response = await NetworkService().patch(
          '$apiUrl/schedule/$scheduleId',
          body: {"name": name});
      final result = Schedule.fromJson(response);
      final updatedItem = _schedules.firstWhere((element) => element.id == result.id);

      updatedItem.name = result.name;

      notifyListeners();
    } catch(e) {
      print('updateSchedule error $e');
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    try {
      await NetworkService().delete(
          '$apiUrl/schedule/$scheduleId');

      _schedules.removeWhere((element) => element.id == scheduleId);

      notifyListeners();
    } catch(e) {
      print('deleteSchedule error $e');
    }
  }
}