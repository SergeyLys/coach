import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/domains/gym_event_coach.dart';
import 'package:flutter_app/domains/sets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/services/network_service.dart';
import 'package:flutter_app/domains/gym_event_trainee.dart';
import 'package:collection/collection.dart';

class CoachEventProvider extends ChangeNotifier {
  final List<CoachEvent> _events = [];
  List<CoachEvent> get events => _events;
  bool isLoading = false;
  bool isCreatingLoading = false;
  String errorMessage = '';

  Future<void> fetchEventsByDate(DateTime start, DateTime end) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await NetworkService().get(
          '$apiUrl/coach-events'
      );

      final List<CoachEvent> result = response.map<CoachEvent>((json) => CoachEvent.fromJson(json)).toList();

      _events.addAll(result);

      isLoading = false;
      notifyListeners();
    } catch(e) {
      print('CoachEventProvider fetchEventsByDate $e');
    }
  }

  Future<void> createEvent(DateTime start, DateTime end, List<String> selectedDays, bool useSmartFiller, String assigneeEmail) async {
    try {
      isCreatingLoading = true;
      notifyListeners();

      final response = await NetworkService().post(
          '$apiUrl/coach-events/create',
        body: {
          'startDate': start.toString(),
          'endDate': end.toString(),
          'repeatDays': selectedDays,
          'repeat': '',
          'smartFiller': useSmartFiller,
          'assigneeEmail': assigneeEmail
        }
      );

      final CoachEvent result = CoachEvent.fromJson(response);

      _events.add(result);

      isCreatingLoading = false;
      notifyListeners();
    } catch(e) {
      isCreatingLoading = false;
      print('CoachEventProvider createEvent error $e');
      rethrow;
    }
  }
}