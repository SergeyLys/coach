import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/domains/user_event.dart';
import 'package:flutter_app/assets/constants.dart';

final mockEvent = {
  "title": 'Title',
  "type": eventTypes['gymAppointment'],
  "duration": 3214234,
  "repeatable": false,
  "repeatPattern": [],
  "dates": [DateTime.now()],
  "owner": 1,
  "details": {
    "squats": [
      {"weight": 50, "reps": 10},
      {"weight": 50, "reps": 10},
      {"weight": 50, "reps": 10}
    ]
  }
};

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<Map<String, dynamic>> _userEvents = [];

  @override
  void initState() {
    super.initState();
    print('Component did mount ${DateTime.now()}');
    setState(() {
      _userEvents = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(DateFormat.yMMMEd().format(DateTime.now()))),
      body: Column(
        children: [
          Text(context.watch<UserProvider>().email),
          (_userEvents.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _userEvents.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text("${_userEvents[index]['title']}"),
                    );
                  })
              : Text("There is no event for today."))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/event-constructor');
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
