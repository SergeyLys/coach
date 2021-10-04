import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/providers/gym_event_provider.dart';
import 'package:flutter_app/screens/schedule_constructor/schedule_constructor.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    context.read<GymEventProvider>().fetchUsersEvents();
  }

  @override
  Widget build(BuildContext context) {
    final String currentDay = DateFormat.E().format(DateTime.now());
    final List<GymEvent> userEvents = context.read<GymEventProvider>().events;

    return Scaffold(
      appBar: AppBar(title: Text(DateFormat.yMMMEd().format(DateTime.now()))),
      body: Column(
        children: [
          (context.read<GymEventProvider>().events.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: userEvents.length,
                  itemBuilder: (context, index) {
                    print(userEvents[index].day);
                    if (userEvents[index].day == currentDay) {
                      return ListTile(
                        title: Text("${userEvents[index].day}"),
                      );
                    }
                    return SizedBox.shrink();
                  })
              : Text("There is no event for today."))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleConstructor(),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class UserEvents extends StatefulWidget {
  const UserEvents({Key? key}) : super(key: key);

  @override
  _UserEventsState createState() => _UserEventsState();
}

class _UserEventsState extends State<UserEvents> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
