import 'package:flutter/material.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/providers/schedule_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/domains/gym_event.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ScheduleConstructor extends StatefulWidget {
  const ScheduleConstructor({Key? key}) : super(key: key);

  @override
  _ScheduleConstructorState createState() => _ScheduleConstructorState();
}

class _ScheduleConstructorState extends State<ScheduleConstructor> {
  List<Widget> _buildExercises(GymEvent event) {
    final currentDate = context.read<ScheduleProvider>().currentDate;
    final forToday = event.day == context.read<ScheduleProvider>().today;

    return event.exercises.map<Widget>((exercise) {
      final maxDate = context.read<ScheduleProvider>().getLatestDate(exercise);

      if (forToday && maxDate != currentDate) {
        context.read<ScheduleProvider>().updateSets(exercise);
      }

      print(exercise.name);
      print(exercise.setsToList());

      return Stack(
        key: ValueKey(exercise.id),
        children: [
          Container(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 30),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            margin: EdgeInsets.only(bottom: 15),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Exercise",
                  ),
                  initialValue: exercise.name,
                  onChanged: (value) {
                    context.read<ScheduleProvider>().setExerciseName(
                        exercise, value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter value';
                    }
                    return null;
                  },
                ),
                Container(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: exercise.sets[maxDate]!.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Container(
                            width: 30,
                            child: TextFormField(
                              style: TextStyle(fontSize: 14),
                              initialValue: exercise.sets[maxDate]![index]['w']
                                  .toString(),
                              decoration: InputDecoration(
                                label: Text(
                                    "Weight", style: TextStyle(fontSize: 10)),
                              ),
                              onChanged: (value) {
                                context.read<ScheduleProvider>()
                                    .editExerciseSet(
                                      exercise,
                                      forToday ? currentDate : maxDate,
                                      index,
                                      'w',
                                      int.parse(value)
                                    );
                              },
                            ),
                          ),
                          Container(
                            width: 30,
                            child: TextFormField(
                              style: TextStyle(fontSize: 14),
                              initialValue: exercise.sets[maxDate]![index]['r']
                                  .toString(),
                              decoration: InputDecoration(
                                  label: Text(
                                      "Reps", style: TextStyle(fontSize: 10)),
                              ),
                              onChanged: (value) {
                                context.read<ScheduleProvider>()
                                    .editExerciseSet(
                                      exercise,
                                      forToday ? currentDate : maxDate,
                                      index,
                                      'r',
                                      int.parse(value)
                                  );
                              },
                            ),
                          ),
                          if (index == exercise.sets[maxDate]!.length - 1) Container(
                              margin: EdgeInsets.only(top: 10),
                              child: IconButton(
                                  onPressed: () {
                                    context.read<ScheduleProvider>()
                                        .addEmptySet(exercise, forToday ? currentDate : maxDate);
                                  },
                                  icon: Icon(Icons.add)
                              )
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (exercise.setsToList().isNotEmpty) charts.LineChart(
                    [
                      charts.Series<ParsedSet, DateTime>(
                        id: exercise.id.toString(),
                        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                        domainFn: (ParsedSet set, _) => set.date,
                        measureFn: (ParsedSet set, _) => set.weight,
                        data: exercise.setsToList(),
                      ),
                    ],
                    animate: false
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                context.read<ScheduleProvider>().removeExercise(exercise);
              },
              icon: Icon(Icons.close),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              onPressed: () {
                context.read<ScheduleProvider>().editExercise(exercise);
              },
              icon: exercise.hasChanges
                  ? Icon(Icons.check, size: 25, color: Colors.green,)
                  : Icon(Icons.check, size: 20, color: Colors.grey),
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sortedEvents = weekDays.map((day) =>
        context.read<ScheduleProvider>().schedule!.events.firstWhere((element) => element.day == day)
    );
    return DefaultTabController(
      initialIndex: weekDays.indexOf(context.read<ScheduleProvider>().today),
      length: weekDays.length,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(DateFormat.yMMMEd().format(DateTime.now())),
          ),
          bottom: context.watch<ScheduleProvider>().schedule == null ? PreferredSize(
            child: Container(),
            preferredSize: Size(0.0, 0.0),
          ) : TabBar(
            labelPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 10),
            tabs: weekDays.map<Widget>((day) => Text(day)).toList(),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Container(
            child: Center(
              child: context.watch<ScheduleProvider>().schedule == null ? TextButton(
                child: Text("Create Schedule"),
                onPressed: () {
                  context.read<ScheduleProvider>().createSchedule(weekDays);
                },
              ) : TabBarView(
                children: sortedEvents.map<Widget>((event) {
                  if (context.read<ScheduleProvider>().isEmptyEvent(event.id)) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 15, top: 15),
                      child: ListView(
                        children: [
                          ..._buildExercises(event),
                          Center(
                              child: TextButton(
                                child: Text("Add exercise"),
                                onPressed: () {
                                  context.read<ScheduleProvider>().addExercise(
                                      event
                                  );
                                },
                              ))
                        ],
                      ),
                    );
                  }

                  return Center(
                      child: TextButton(
                        child: Text("Add exercise"),
                        onPressed: () {
                          context.read<ScheduleProvider>().addExercise(
                              event
                          );
                        },
                      ));
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
