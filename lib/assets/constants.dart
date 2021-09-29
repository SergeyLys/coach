import 'package:intl/intl.dart';

const String apiUrl="http://0.0.0.0:3005";

final Map<String, String> eventTypes = {
  'gymAppointment': 'Gym',
  'meeting': 'Meeting',
};

final List<String> weekDays = DateFormat.E().dateSymbols.SHORTWEEKDAYS;