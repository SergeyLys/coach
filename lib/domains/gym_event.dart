class GymEvent {
  int id;
  String? repeat;
  List<String> repeatDays;
  bool smartFiller;

  GymEvent({
    required this.id,
    required this.repeat,
    required this.repeatDays,
    required this.smartFiller,
  });
}