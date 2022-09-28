import 'package:intl/intl.dart';

const String apiUrl="http://localhost:3005";

final Map<String, String> eventTypes = {
  'gymAppointment': 'Gym',
  'meeting': 'Meeting',
};

final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

final List<String> userRoles = <String>['Trainee', 'Coach'];