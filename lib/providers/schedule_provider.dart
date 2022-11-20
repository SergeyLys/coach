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

  Future<void> fetchSchedules(int userId) async {
    try {
      final response = await NetworkService().get(
        '$apiUrl/schedules/by-user/$userId'
      );

      final result = parseEntities(response);

      _schedules = result;
      notifyListeners();
    } catch(e) {
      print('fetchSchedules error $e');
    }
  }


}