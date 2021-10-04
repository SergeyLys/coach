import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/src/provider.dart';
import 'package:flutter_app/providers/gym_event_provider.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/screens/schedule_constructor/schedule_detail.dart';

class ScheduleConstructor extends StatefulWidget {
  const ScheduleConstructor({Key? key}) : super(key: key);

  @override
  _ScheduleConstructorState createState() => _ScheduleConstructorState();
}

class _ScheduleConstructorState extends State<ScheduleConstructor> {
  Map<String, dynamic> eventDetails = {};

  void _handleChangeDetails(String value, String forDay) {
    eventDetails[forDay] = value;
  }

  Widget _buildEventDetails(GymEvent value) {
    return ScheduleDetail(
        key: GlobalKey(),
        event: value, onChangeDetails: _handleChangeDetails);
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: weekDays.length,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: TextFormField(
              style: TextStyle(color: Colors.white, fontSize: 20),
              initialValue: "Event title",
              onChanged: (value) {

              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter event title';
                }
                return null;
              },
            ),
          ),
          bottom: TabBar(
            labelPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 10),
            tabs: weekDays.map<Widget>((day) {
              return Text(day);
            }).toList(),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: TabBarView(
            children: [
              ...weekDays.map<Widget>((day) {
                if (context.read<GymEventProvider>().isEmpty(day)) {
                  return ListView(
                    children: [
                      _buildEventDetails(
                          context.watch<GymEventProvider>().getEventByDay(day)),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text(
                                  'Save changes',
                                ),
                              ),
                            ],
                          )),
                    ],
                  );
                }

                return Center(
                    child: TextButton(
                      child: Text("Add exercise"),
                      onPressed: () {
                        context.read<GymEventProvider>().addExercise(
                            day, Exercise(
                            id: Random().nextInt(9999999),
                            name: '',
                            sets: [Exercise.blankSet]
                        ));
                      },
                    ));
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
