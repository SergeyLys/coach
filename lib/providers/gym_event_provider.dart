import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_app/services/network_service.dart';
import 'package:flutter_app/assets/constants.dart';

class Exercise {
  int id;

  String name;

  List<Map<String, int>> sets;

  static Map<String, int> blankSet = {"w": 0, "r": 0};

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
        id: json['id'] as int,
        name: json['name'] as String,
        sets: json['sets'].map<Map<String, int>>((set) => ({
          "w": set["w"] as int,
          "r": set["r"] as int
        })).toList()
    );
  }
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
      exercises: json['exercises'].map<Exercise>((exercise) => Exercise.fromJson(exercise)).toList() as List<Exercise>
    );
  }
}

class GymEventProvider extends ChangeNotifier {
  late List<GymEvent> _events = [];

  get events => _events;

  void setEvent(List<GymEvent> events) {
    _events = events;
    notifyListeners();
  }

  List<GymEvent> parseEvents(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<GymEvent>((json) => GymEvent.fromJson(json)).toList();
  }

  Future<void> fetchEvent(String day) async {
    try {
      final response = await NetworkService()
          .get('$apiUrl/events/$day');
      setEvent(parseEvents(response));
    } catch(e) {
      print('== error $e');
    }
  }

  Future<void> fetchUsersEvents() async {
    try {
      final response = await NetworkService()
          .get('$apiUrl/events');
      final events = parseEvents(response);
      setEvent(events);
    } catch(e) {
      print('213 error $e');
    }
  }

  GymEvent getEventByDay(String day) {
    return _events.firstWhere((element) => element.day == day);
  }

  bool isEmpty(String day) {
    return _events.any((element) => element.day == day && element.exercises.isNotEmpty);
  }

  Future<void> addExercise(String day, Exercise exercise) async {
    // final GymEvent event;
    //
    // if (_events.any((element) => element.day == day)) {
    //   event = _events.firstWhere((element) => element.day == day);
    // } else {
    //   event = GymEvent(id: Random().nextInt(9999999), day: day, exercises: []);
    //   _events.add(event);
    // }
    //
    // event.exercises.add(exercise);
    try {
      final response = await NetworkService().post(
          '$apiUrl/exercise',
          body: <String, dynamic>{
            'name': exercise.name,
            'sets': exercise.sets,
            'eventName': day
          });
      print(response);
    } catch(e) {
      print('error $e');
    }

    notifyListeners();
  }

  void removeExercise(GymEvent event, int exerciseId) {
    event.exercises.removeWhere((row) => row.id == exerciseId);
    notifyListeners();
  }

  void setExerciseName(Exercise exercise, String name) {
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

  void editExerciseSet(Exercise exercise, int index, String field, int value) {
    exercise.sets[index] = {...exercise.sets[index], field: value};
    notifyListeners();
  }
}
