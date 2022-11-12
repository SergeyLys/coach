import 'package:intl/intl.dart';

const String apiUrlProd="http://icoach-env.eba-gnpu2np8.eu-west-2.elasticbeanstalk.com";
const String apiUrlDev="http://localhost:3005";
const String apiUrl = apiUrlDev;

final Map<String, String> eventTypes = {
  'gymAppointment': 'Gym',
  'meeting': 'Meeting',
};

final List<String> weekDaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

final List<String> userRoles = <String>['Trainee', 'Coach'];

final List<String> months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

final List<String> weekdays = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];