import './exercise.dart';

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