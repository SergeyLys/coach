class UserEvent {
  late String title;
  late String type;
  late int duration;
  late bool repeatable;
  late List<String> repeatPattern;
  late List<String> dates;
  late int owner;

  UserEvent(this.title,
      this.type,
      this.duration,
      this.repeatable,
      this.repeatPattern,
      this.dates,
      this.owner);

  UserEvent.fromJson(Map<String, dynamic> responseData)
      : title = responseData['title'],
        type = responseData['type'],
        duration = responseData['duration'],
        repeatable = responseData['repeatable'],
        repeatPattern = responseData['repeatPattern'],
        dates = responseData['dates'],
        owner = responseData['owner'];
}