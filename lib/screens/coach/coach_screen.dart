import 'package:flutter/material.dart';
import 'package:flutter_app/components/main_screen.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/screens/coach/components/timeline_item.dart';
import 'package:provider/src/provider.dart';


import 'package:flutter_app/assets/utils.dart';
import './components/event_card.dart';

enum Menu { update, remove }

class CoachScreen extends StatefulWidget {
  const CoachScreen({Key? key}) : super(key: key);

  @override
  _CoachScreenState createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  late double _scrollOffset = 0;
  final double _paddingTop = 20;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { });
  }


  @override
  void dispose() {
    super.dispose();
  }

  _onEndScroll(ScrollMetrics metrics) {
    setState(() {
      _scrollOffset = metrics.pixels;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().id;

    return MainScreen(
      isLoading: false,
      onFetchDays: (DateTime start, DateTime end) {},
      onPostFrameCallback: (DateTime start, DateTime end) {},
      child: (DateTime date, double topOffset) {
        List<double> hours = getDateHours(date);

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollEndNotification) {
              _onEndScroll(scrollNotification.metrics);
            }
            return false;
          },
          child: SingleChildScrollView(
            child: Container(
              key: ValueKey(date),
              padding: EdgeInsets.only(top: _paddingTop),
              height: 1550,
              child: Stack(
                children: [
                  ...hours.map((index) => TimelineItem(position: index)),
                  EventCard(
                      initialTopOffset: topOffset + _paddingTop,
                      hours: hours,
                      scrollPosition: _scrollOffset,
                      startDate: date.add(const Duration(hours: 3)),
                      endDate: date.add(const Duration(hours: 4))
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
