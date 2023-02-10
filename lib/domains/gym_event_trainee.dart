import 'package:flutter_app/domains/sets.dart';

import './gym_event.dart';
import './exercise.dart';

class TraineeEvent extends GymEvent {
  Exercise exercise;
  List<SetsModel> sets;

  TraineeEvent(
      {id,
      repeat,
      repeatDays,
      smartFiller,
      required this.exercise,
      required this.sets})
      : super(
            id: id,
            repeat: repeat,
            repeatDays: repeatDays,
            smartFiller: smartFiller);

  factory TraineeEvent.fromJson(Map<String, dynamic> json) {
    return TraineeEvent(
      id: json['id'] as int,
      exercise: Exercise.fromJson(json['exercise']),
      sets: json['sets']
          .map<SetsModel>((element) => SetsModel.fromJson(element))
          .toList(),
      repeatDays: List<String>.from(json['repeatDays']),
      smartFiller: json['smartFiller'],
    );
  }
}
