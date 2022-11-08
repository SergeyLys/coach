import './gym_event.dart';
import './user.dart';

class CoachEvent extends GymEvent {
  List<User> trainees;

  CoachEvent({id, required this.trainees}) : super(id: id);

  factory CoachEvent.fromJson(Map<String, dynamic> json) {
    return CoachEvent(
        id: json['id'] as int,
        trainees: json['trainees']?.map<User>((user) => User.fromJson(user)).toList() as List<User>
    );
  }
}