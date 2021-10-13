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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(DateFormat.yMMMEd().format(DateTime.now()))),
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              color: Colors.orangeAccent,
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.food_bank_outlined, size: 70, color: Colors.white),
                    Text('Nutrition', style: TextStyle(fontSize: 40, color: Colors.white))
                  ],)
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleConstructor(),
                  ),
                );
              },
              child: Container(
                color: Colors.lightBlueAccent,
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports, size: 70, color: Colors.white),
                        Text('Sports', style: TextStyle(fontSize: 40, color: Colors.white))
                      ],)
                ),
              ),
            ),
          ),
        ],
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
