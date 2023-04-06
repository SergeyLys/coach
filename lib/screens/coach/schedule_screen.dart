import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/assets/utils.dart';
import 'package:flutter_app/domains/gym_event_coach.dart';
import 'package:flutter_app/providers/coach-event_provider.dart';
import 'package:flutter_app/screens/trainee/trainee_screen.dart';
import 'package:flutter_app/screens/trainee/trainee_screen_arguments.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/assets/constants.dart';
import 'components/event_card.dart';
import 'components/create_event_dialog.dart';
import 'components/timeline_item.dart';

class ScheduleScreen extends StatefulWidget {
  final DateTime date;
  final double topOffset;
  final List<CoachEvent> events;
  const ScheduleScreen({Key? key, required this.date, required this.topOffset, required this.events}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late double _scrollOffset = 0;
  final double _paddingTop = 20;
  late List<double> _hours = [];
  late List<List<CoachEvent>> _overlappedEvents = [];
  late List<CoachEvent> _currentDateEvents = [];

  @override
  void initState() {
    super.initState();

    _hours = getDateHours();

    _currentDateEvents = _getEventsForCurrentDate();

    _overlappedEvents = _portionEvents(_currentDateEvents);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { });
  }

  _onEndScroll(ScrollMetrics metrics) {
    setState(() {
      _scrollOffset = metrics.pixels;
    });
  }

  _handleTimelineTap(double position) async {
    double offset = widget.topOffset + _paddingTop;
    int selected = ((position + _scrollOffset - offset) / 60).truncate();
    final data = await openDialog(widget.date, TimeOfDay(hour: selected, minute: 0), null);
    context.read<CoachEventProvider>().createEvent(
        data!['start'], data['end'], data['selectedDays'], data['useSmartFiller'], data['assigneeEmail']
    );
  }

  _handleEventLongPress(CoachEvent event) async {
    DateTime startDate = DateTime.parse(event.startDate).toLocal();
    final data = await openDialog(widget.date, TimeOfDay(hour: startDate.hour, minute: startDate.minute), event);
    context.read<CoachEventProvider>().updateEvent(
        data!['event'], data['start'], data['end'], data['selectedDays'], data['useSmartFiller'], data['assigneeEmail']
    );
  }

  _handleEventTap(CoachEvent event) {
    Navigator.pushNamed(
      context,
      TraineeScreen.routeName,
      arguments: TraineeScreenArguments(
        event.assignee.id
      ),
    );
  }

  _handleChangeEventRange(CoachEvent event, double top, double height) {
    final startTime = getTimeFromTimeline(widget.date, top).toLocal();
    final endTime = getTimeFromTimeline(widget.date, top + height).toLocal();

    final int foundIndex = _currentDateEvents.indexOf(event);

    setState(() {
      _currentDateEvents[foundIndex].startDate = startTime.toString();
      _currentDateEvents[foundIndex].endDate = endTime.toString();
      _overlappedEvents = _portionEvents(_currentDateEvents);
    });
  }

  List<List<CoachEvent>> _portionEvents(List<CoachEvent> list) {
    if (list.isEmpty) return [list];

    final buffer = [...list];

    DateTime? getMaxEnd(List<CoachEvent> array) {
      if (array.isEmpty) return null;
      array.sort((a,b) {
        if (DateTime.parse(a.endDate).isBefore(DateTime.parse(b.endDate))) {
          return 1;
        }
        if (DateTime.parse(a.endDate).isAfter(DateTime.parse(b.endDate))) {
          return -1;
        }
        return 0;
      });
      return DateTime.parse(array[0].endDate);
    };

    buffer.sort((a, b) {
      if (DateTime.parse(a.startDate).isBefore(DateTime.parse(b.startDate))) {
        return -1;
      }
      if (DateTime.parse(a.startDate).isAfter(DateTime.parse(b.startDate))) {
        return 1;
      }
      return 0;
    });

    List<List<CoachEvent>> result = [];
    int j = 0;
    result.insert(j, [buffer[0]]);

    for (var i=1;i<buffer.length;i++) {
      if ( (DateTime.parse(buffer[i].startDate).isAfter(DateTime.parse(buffer[i-1].startDate)) ||
          DateTime.parse(buffer[i].startDate).isAtSameMomentAs(DateTime.parse(buffer[i-1].startDate)))
          &&
          (DateTime.parse(buffer[i].startDate).isBefore(getMaxEnd(result[j])!))
      ) {
        result[j].add(buffer[i]);
      } else {
        j++;
        result.insert(j, [buffer[i]]);
      }
    }
    return result;
  }

  List<CoachEvent> _getEventsForCurrentDate() {
    final today = DateTime(widget.date.year, widget.date.month, widget.date.day);

    return widget.events.where((element)
    {
      final startDate = DateTime.parse(element.startDate).toLocal();
      final endDate = DateTime.parse(element.endDate).toLocal();
      final aDate = DateTime(startDate.year, startDate.month, startDate.day);
      final bDate = DateTime(endDate.year, endDate.month, endDate.day);
      return aDate == today && bDate == today;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          _onEndScroll(scrollNotification.metrics);
        }
        return false;
      },
      child: SingleChildScrollView(
        child: Container(
          key: ValueKey(widget.date),
          padding: EdgeInsets.only(top: _paddingTop),
          height: 1550,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                children: [
                  ..._hours.map((index) => TimelineItem(position: index, onLongTap: _handleTimelineTap)),
                  ..._currentDateEvents.map((item)
                  {
                    int overlappedPortionIndex = _overlappedEvents.indexWhere((list) => list.contains(item));
                    List<CoachEvent> portion = _overlappedEvents[overlappedPortionIndex];
                    double width = (constraints.maxWidth - 45) / portion.length;
                    int currentOrder = portion.indexOf(item);

                    // print('portion ${portion.map((e) => e.id)}');
                    // print('currentOrder $currentOrder $_overlappedEvents');
                    //
                    // Random random = Random();
                    // Color tempcol = Color.fromRGBO(
                    //   random.nextInt(255),
                    //   random.nextInt(255),
                    //   random.nextInt(255),
                    //   1,
                    // );
                        return EventCard(
                            initialTopOffset: widget.topOffset + _paddingTop,
                            hours: _hours,
                            scrollPosition: _scrollOffset,
                            event: item,
                            onTap: _handleEventTap,
                            onLongPress: _handleEventLongPress,
                            width: width,
                            left: 45 + (width * currentOrder),
                            handleChangeEventRange: _handleChangeEventRange,
                            events: widget.events,
                            // bg: tempcol,
                            currentDate: widget.date,
                        );
                      })
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> openDialog(DateTime currentDate, TimeOfDay startTime, CoachEvent? event) => showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => ConfigureCoachEventDialog(
        onSubmitCallback: submitCoachEvent,
        title: 'Configure event',
        currentDate: currentDate,
        startTime: startTime,
        event: event
      )
  );

  void submitCoachEvent(CoachEvent? event, DateTime start, DateTime end, List<String> selectedDays, bool useSmartFiller, String assigneeEmail) {
    Navigator.of(context).pop({
      'event': event, 'start': start, 'end': end, 'selectedDays': selectedDays, 'useSmartFiller': useSmartFiller, 'assigneeEmail': assigneeEmail
    });
  }
}

/*
{
  "1": [["2"], ["3"]]
}
*/
