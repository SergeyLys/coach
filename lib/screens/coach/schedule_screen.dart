import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/assets/utils.dart';
import 'package:flutter_app/domains/gym_event_coach.dart';
import 'package:flutter_app/providers/coach-event_provider.dart';
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

  @override
  void initState() {
    super.initState();

    _hours = getDateHours();

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
    openDialog(widget.date, TimeOfDay(hour: selected, minute: 0), null);
  }

  _handleEventLongPress(CoachEvent event) {
    DateTime startDate = DateTime.parse(event.startDate).toLocal();
    openDialog(widget.date, TimeOfDay(hour: startDate.hour, minute: startDate.minute), event);
  }

  _handleEventTap(CoachEvent event) {
    print(event.assignee);
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
          child: Stack(
            children: [
              ..._hours.map((index) => TimelineItem(position: index, onLongTap: _handleTimelineTap)),
              ...widget.events.map((item) =>
                  EventCard(
                      initialTopOffset: widget.topOffset + _paddingTop,
                      hours: _hours,
                      scrollPosition: _scrollOffset,
                      event: item,
                      onTap: _handleEventTap,
                      onLongPress: _handleEventLongPress
                  ),
              )
            ],
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

  void submitCoachEvent() {
    Navigator.of(context).pop();
  }
}
