import 'package:flutter/material.dart';
import 'package:flutter_app/domains/schedule.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:flutter_app/providers/schedule_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/domains/gym_event.dart';
import 'package:flutter_app/domains/exercise.dart';

class Events extends StatefulWidget {
  const Events({Key? key, required this.userId, required this.userName}) : super(key: key);
  final int userId;
  final String userName;

  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
  List<Widget> _buildExercises(GymEvent event) {
    final currentDate = context.read<EventProvider>().currentDate;
    final forToday = event.day == context.read<EventProvider>().today;

    return event.exercises.map<Widget>((exercise) {
      final maxDate = context.read<EventProvider>().getLatestDate(exercise);

      if (forToday && maxDate != currentDate) {
        context.read<EventProvider>().updateSets(exercise);
      }

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
                    context.read<EventProvider>().setExerciseName(
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
                                context.read<EventProvider>()
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
                                context.read<EventProvider>()
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
                                    context.read<EventProvider>()
                                        .addEmptySet(exercise, forToday ? currentDate : maxDate);
                                  },
                                  icon: Icon(Icons.add)
                              )
                          )
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                context.read<EventProvider>().removeExercise(exercise);
              },
              icon: Icon(Icons.close),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              onPressed: exercise.hasChanges ? () {
                context.read<EventProvider>().editExercise(exercise);
              } : null,
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
    return FutureBuilder(
        future: context.read<EventProvider>().fetchEventsByUserId(widget.userId),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          final sortedEvents = weekDays.map((day) {
            return context.watch<EventProvider>().events.firstWhere((element) => element.day == day);
          });
          final displayDate = DateFormat.yMMMEd().format(DateTime.now());
          final userName = widget.userName;

          return DefaultTabController(
            initialIndex: weekDays.indexOf(context.read<EventProvider>().today),
            length: weekDays.length,
            child: Scaffold(
              appBar: AppBar(
                title: Center(
                  child: Text('$userName, $displayDate'),
                ),
                bottom: TabBar(
                  labelPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 10),
                  tabs: weekDays.map<Widget>((day) => Text(day)).toList(),
                ),
              ),
              body: Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Container(
                  child: Center(
                    child: TabBarView(
                      children: sortedEvents.map<Widget>((event) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 15, top: 15),
                          child: ListView(
                            children: [
                              ..._buildExercises(event),
                              Center(
                                child: TextButton(
                                  child: Text("Add exercise"),
                                  onPressed: () {
                                    context.read<EventProvider>().addExercise(
                                        event.id
                                    );
                                  },
                                ))
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}
