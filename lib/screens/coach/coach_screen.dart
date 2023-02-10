import 'package:flutter/material.dart';
import 'package:flutter_app/components/main_screen.dart';
import 'package:flutter_app/providers/coach-event_provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/screens/coach/schedule_screen.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';




enum Menu { update, remove }

class CoachScreen extends StatefulWidget {
  const CoachScreen({Key? key}) : super(key: key);

  @override
  _CoachScreenState createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

    });
  }


  @override
  void dispose() {
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().id;
    return MainScreen(
      isLoading: false,
      onFetchDays: (DateTime start, DateTime end) {},
      onPostFrameCallback: (start, end) => Provider.of<CoachEventProvider>(context, listen: false).fetchEventsByDate(start, end),
      child: (DateTime date, double topOffset) {
        return Consumer<CoachEventProvider>(
            builder: (context, provider, child) => Visibility(
                visible: !provider.isLoading,
                replacement: const Center(
                  child: CircularProgressIndicator(),
                ),
                child: ScheduleScreen(date: date, topOffset: topOffset, events: provider.events)
            )
        );
      },
    );
  }
}
