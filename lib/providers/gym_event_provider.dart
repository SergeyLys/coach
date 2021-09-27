import 'package:flutter/cupertino.dart';
import 'dart:math';

class Exercise {
  int id;

  String name;

  List<Map<String, int>> sets;

  static Map<String, int> blankSet = {"w": 0, "r": 0};

  Exercise({
    required this.name,
    required this.sets,
  }) : id = Random().nextInt(9999999);
}

class GymEvent {
  int id;

  String day;

  List<Exercise> exercises;

  GymEvent({required this.day, required this.exercises})
      : id = Random().nextInt(9999999);
}

class GymEventProvider extends ChangeNotifier {
  late List<GymEvent> _events = [
    GymEvent(day: 'Mon', exercises: [
      Exercise(name: "Squats 1", sets: [
        {"w": 60, "r": 10},
        {"w": 60, "r": 10},
        {"w": 60, "r": 10},
        {"w": 60, "r": 10},
        {"w": 60, "r": 10},
        {"w": 60, "r": 10}
      ]),
      Exercise(name: "Squats 2", sets: [
        {"w": 60, "r": 10},
        {"w": 60, "r": 10},
        {"w": 60, "r": 10}
      ])
    ])
  ];

  void setEvent(List<GymEvent> events) {
    _events = events;
    notifyListeners();
  }

  List<GymEvent> getAllEvents() {
    return _events;
  }

  GymEvent getEventByDay(String day) {
    return _events.firstWhere((element) => element.day == day);
  }

  bool isEmpty(String day) {
    return _events.any((element) => element.day == day);
  }

  void addExercise(String day, Exercise exercise) {
    final GymEvent event;

    if (_events.any((element) => element.day == day)) {
      event = _events.firstWhere((element) => element.day == day);
    } else {
      event = GymEvent(day: day, exercises: []);
      _events.add(event);
    }

    event.exercises.add(exercise);

    notifyListeners();
  }

  void removeExercise(String day, int exerciseId) {
    final event = getEventByDay(day);
    event.exercises.removeWhere((row) => row.id == exerciseId);
    notifyListeners();
  }

  void setExerciseName(String day, int exerciseId, String name) {
    final event = getEventByDay(day);
    final exercise =
        event.exercises.firstWhere((element) => element.id == exerciseId);
    exercise.name = name;
    notifyListeners();
  }

  void addEmptySet(String day, int exerciseId) {
    final event = getEventByDay(day);
    final exercise =
        event.exercises.firstWhere((element) => element.id == exerciseId);
    exercise.sets.add(Exercise.blankSet);
    notifyListeners();
  }
}
