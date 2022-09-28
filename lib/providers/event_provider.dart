import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/services/network_service.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/domains/gym_event.dart';
import 'package:flutter_app/domains/schedule.dart';

class EventProvider extends ChangeNotifier {
  final String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final String _today = DateFormat.E().format(DateTime.now());
  List<GymEvent> _events = [];

  List<GymEvent> get events => _events;

  String get currentDate => _currentDate;

  String get today => _today;

  GymEvent getEventById(int id) {
    return events.firstWhere((element) => element.id == id);
  }

  bool isEmptyEvent(int id) {
    return events.any((element) => element.id == id && element.exercises.isNotEmpty);
  }

  List<GymEvent> parseEntities(List<dynamic> responseBody) => responseBody.map<GymEvent>((json) => GymEvent.fromJson(json)).toList();

  Future<void> fetchEventsByUserId(int userId) async {
    try {
      final response = await NetworkService().get(
          '$apiUrl/events/by-user/$userId'
      );

      final result = parseEntities(response);

      _events = result;
      notifyListeners();
    } catch(e) {
      print('fetchEvents error $e');
    }
  }

  Future<void> addExercise(int eventId) async {
    final currentIndex = weekDays.indexOf(today);
    final event = events.firstWhere((element) => element.id == eventId);
    final selectedIndex = weekDays.indexOf(event.day);
    final dayDifference = currentIndex - selectedIndex;
    final parsedDate = DateTime.parse(currentDate);
    final date = DateTime(parsedDate.year, parsedDate.month, parsedDate.day - dayDifference);

    try {
      final response = await NetworkService().post(
          '$apiUrl/exercise',
          body: <String, dynamic>{
            'eventId': eventId,
            'date': date.toString()
          });
      final result = Exercise.fromJson(response);
      event.exercises.add(result);
      notifyListeners();
    } catch(e) {
      print('addExercise error $e');
    }
  }

  Future<void> removeExercise(Exercise exercise) async {
    final event = events.firstWhere((element) => element.exercises.firstWhereOrNull((ex) => ex.id == exercise.id) != null);
    try {
      await NetworkService().delete(
          '$apiUrl/exercise/${exercise.id}');
      event.exercises.removeWhere((element) => element.id == exercise.id);
      notifyListeners();
    } catch(e) {
      print('removeExercise error $e');
    }
  }

  Future<void> editExercise(Exercise exercise) async {
    try {
      await NetworkService().patch(
          '$apiUrl/exercise/${exercise.id}',
          body: {
            "name": exercise.name,
            "sets": exercise.sets,
          }
      );
      exercise.hasChanges = false;
      notifyListeners();
    } catch(e) {
      print('editExercise error $e');
    }
  }

  String getLatestDate(Exercise exercise) {
    final buffer = [];
    for (final mapEntry in exercise.sets.entries) {
      buffer.add(mapEntry.key);
    }
    final maxDate = buffer.reduce((a,b) => DateTime.parse(a as String).isAfter(DateTime.parse(b as String)) ? a : b);

    return maxDate;
  }

  void updateSets(Exercise exercise) {
    final maxDate = getLatestDate(exercise);
    final latestSets = exercise.sets[maxDate];
    exercise.sets[currentDate] = [...latestSets!];
  }

  void addEmptySet(Exercise exercise, String date) {
    exercise.sets[date]!.add(Exercise.blankSet);
    exercise.hasChanges = true;
    notifyListeners();
  }

  void setExerciseName(Exercise exercise, String name) {
    exercise.name = name;
    exercise.hasChanges = true;
    notifyListeners();
  }

  void editExerciseSet(Exercise exercise, String date, int index, String field, int value) {
    exercise.sets[date]![index] = {...exercise.sets[date]![index], field: value};
    exercise.hasChanges = true;
    notifyListeners();
  }
}