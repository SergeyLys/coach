import 'package:flutter/material.dart';
import 'package:flutter_app/providers/schedule_provider.dart';
import 'dart:math';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/providers/gym_event_provider.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/screens/schedule_constructor/schedule_detail.dart';

class ScheduleConstructor extends StatefulWidget {
  const ScheduleConstructor({Key? key}) : super(key: key);

  @override
  _ScheduleConstructorState createState() => _ScheduleConstructorState();
}

class _ScheduleConstructorState extends State<ScheduleConstructor> {
  final String _currentDay = DateFormat.E().format(DateTime.now());

  Widget _buildEventDetails(GymEvent value) {
    return ScheduleDetail(
        key: GlobalKey(),
        event: value);
  }

  Widget _buildSaveButton() {
    return Container(
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
        ));
  }

  Future<void> getEvents() {
    return context.read<GymEventProvider>().fetchUsersEvents();
  }

  Future<void> getSchedules() {
    return context.read<ScheduleProvider>().fetchSchedules();
  }

  @override
  Widget build(BuildContext context) {


      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(DateFormat.yMMMEd().format(DateTime.now())),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: FutureBuilder(
            future: getSchedules(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (context.watch<ScheduleProvider>().schedules.isEmpty) {
                return Container(
                  child: Center(
                    child: TextButton(
                      child: Text("Create Schedule"),
                      onPressed: () {
                        context.read<ScheduleProvider>().createSchedule(weekDays);
                      },
                    ),
                  ),
                );
              }

              return SizedBox.shrink();
            },
          ),
        ),
      );


    // return DefaultTabController(
    //   initialIndex: weekDays.indexOf(_currentDay),
    //   length: weekDays.length,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: Center(
    //         child: Text(DateFormat.yMMMEd().format(DateTime.now())),
    //       ),
    //       bottom: TabBar(
    //         labelPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 10),
    //         tabs: weekDays.map<Widget>((day) => Text(day)).toList(),
    //       ),
    //     ),
    //     body: Container(
    //       padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
    //       child: FutureBuilder(
    //         future: getSchedules(),
    //         builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
    //
    //           if (snapshot.connectionState == ConnectionState.waiting) {
    //             return Center(child: CircularProgressIndicator());
    //           }
    //
    //           return TabBarView(
    //             children: [
    //               ...weekDays.map<Widget>((day) {
    //                 if (context.read<GymEventProvider>().isEmpty(day)) {
    //                   return ListView(
    //                     children: [
    //                       _buildEventDetails(
    //                           context.watch<GymEventProvider>().getEventByDay(day)),
    //                       _buildSaveButton(),
    //                     ],
    //                   );
    //                 }
    //
    //                 return Center(
    //                     child: TextButton(
    //                       child: Text("Add exercise"),
    //                       onPressed: () {
    //                         context.read<GymEventProvider>().addExercise(
    //                             day, Exercise(
    //                             id: Random().nextInt(9999999),
    //                             name: '',
    //                             sets: [Exercise.blankSet]
    //                         ));
    //                       },
    //                     ));
    //               }).toList(),
    //             ],
    //           );
    //         },
    //       ),
    //     ),
    //   ),
    // );
  }
}
