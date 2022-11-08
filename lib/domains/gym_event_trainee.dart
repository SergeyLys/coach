import 'package:flutter_app/domains/sets.dart';

import './gym_event.dart';
import './exercise.dart';

class TraineeEvent extends GymEvent {
  Exercise exercise;
  List<SetsModel> sets;
  List<String> repeatDays;
  bool smartFiller;

  TraineeEvent({id, required this.exercise, required this.sets, required this.repeatDays, required this.smartFiller}) : super(id: id);

  factory TraineeEvent.fromJson(Map<String, dynamic> json) {
    return TraineeEvent(
      id: json['id'] as int,
      exercise: Exercise.fromJson(json['exercise']),
      sets: json['sets'].map<SetsModel>((element) => SetsModel.fromJson(element)).toList(),
      repeatDays: List<String>.from(json['repeatDays']),
      smartFiller: json['smartFiller'],
    );
  }
}