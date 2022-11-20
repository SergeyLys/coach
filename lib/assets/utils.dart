import 'package:flutter/material.dart';
import 'package:flutter_app/assets/constants.dart';

List<dynamic> getDaysForPeriod(int month, int year, int? from, DateTime? to) {
  final List<dynamic> days = [];
  late int day = 1;

  if (from != null) {
    day += from - 1;
  }

  final DateTime startDate = DateTime(year, month, day);

  var currentDate = startDate;

  while (currentDate.month == month) {
    days.add(currentDate);

    if (to != null && DateUtils.isSameDay(currentDate, to)) {
      break;
    }

    currentDate = DateTime(year, month, currentDate.day + 1);
  }

  return days;
}

Map<String, dynamic> getToday() {
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;
  final date = DateTime(now.year, now.month, now.day);

  return {'month': currentMonth, 'year': currentYear, 'date': date};
}

int getDifferenceInMinutes(DateTime start, DateTime end) {
  Duration diff = end.difference(start);
  return diff.inMinutes;
}

List<double> getDateHours(DateTime date) {
  DateTime dt2 = date;
  DateTime dt1 = date.add(const Duration(hours: 24));
  Duration diff = dt1.difference(dt2);

  int hoursInMinutes = diff.inMinutes ?? minutesInDay;
  int rowsCount = hoursInMinutes ~/ 15;

  return List.generate(rowsCount+1, (index) => index * 15);
}

double getClosestNumber(double input, List<double> source) {
  double curr = source[0];
  double diff = (input-curr).abs();
  for (int val = 0; val < source.length; val++) {
    double newdiff = (input - source[val]).abs();
    if (newdiff < diff) {
      diff = newdiff;
      curr = source[val];
    }
  }
  return curr;
}