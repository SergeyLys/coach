import './gym_event.dart';
import './exercise.dart';

class TraineeEvent extends GymEvent {
  List<Exercise> exercises;

  TraineeEvent({id, day, required this.exercises}) : super(id: id, day: day);

  factory TraineeEvent.fromJson(Map<String, dynamic> json) {
    return TraineeEvent(
        id: json['id'] as int,
        day: json['day'] as String,
        exercises: json['exercises']?.map<Exercise>((exercise) => Exercise.fromJson(exercise)).toList() as List<Exercise>,
    );
  }
}