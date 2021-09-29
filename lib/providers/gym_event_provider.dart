import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:flutter_app/services/network_service.dart';
import 'package:flutter_app/assets/constants.dart';

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

  GymEvent({required this.id, required this.day, required this.exercises});

  factory GymEvent.fromJson(Map<String, dynamic> json) {
    return GymEvent(
      id: json['id'] as int,
      day: json['day'] as String,
      exercises: json['exercises']
    );
  }
}

class GymEventProvider extends ChangeNotifier {
  late List<GymEvent> _events = [
    // GymEvent(day: 'Mon', exercises: [
    //   Exercise(name: "Squats 1", sets: [
    //     {"w": 60, "r": 10},
    //     {"w": 60, "r": 10},
    //     {"w": 60, "r": 10},
    //     {"w": 60, "r": 10},
    //     {"w": 60, "r": 10},
    //     {"w": 60, "r": 10}
    //   ]),
    //   Exercise(name: "Squats 2", sets: [
    //     {"w": 60, "r": 10},
    //     {"w": 60, "r": 10},
    //     {"w": 60, "r": 10}
    //   ])
    // ])
  ];

  get events => _events;

  void setEvent(List<GymEvent> events) {
    _events = events;
    notifyListeners();
  }

  Future<void> fetchEvent(String day) async {
    try {
      final response = await NetworkService()
          .get('$apiUrl/events/$day');
      print(response);
      // setEvent(response);
    } catch(e) {
      print('== error $e');
    }
  }

  Future<void> fetchUsersEvents() async {
    try {
      final response = await NetworkService()
          .get('$apiUrl/events');
      print(response);
      // setEvent(response as List<GymEvent>);
    } catch(e) {
      print('213 error $e');
    }
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
