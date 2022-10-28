import 'package:flutter/material.dart';
import 'package:flutter_app/components/main_screen.dart';
import 'package:flutter_app/domains/schedule.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:flutter_app/providers/schedule_provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/domains/gym_event.dart';
import 'package:flutter_app/domains/exercise.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({Key? key}) : super(key: key);

  @override
  _CoachScreenState createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().id;
    return FutureBuilder(
        future: context.read<EventProvider>().fetchEventsByUserId(userId),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          print(context.read<EventProvider>().events);
          return MainScreen(
            child: () {
              return Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Container(
                  child: Center(
                      child: TabBarView(
                        children: [
                          Text('Test 1'),
                          Text('Test 2'),
                          Text('Test 3'),
                          Text('Test 4'),
                          Text('Test 5'),
                          Text('Test 6'),
                          Text('Test 7'),
                        ],
                      )
                  ),
                ),
              );
            }
          );
        }
    );
  }
}
