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
import 'package:flutter_app/domains/gym_event_trainee.dart';
import 'package:flutter_app/domains/exercise.dart';

class TraineeScreen extends StatefulWidget {
  const TraineeScreen({Key? key}) : super(key: key);

  @override
  _TraineeScreenState createState() => _TraineeScreenState();
}

class _TraineeScreenState extends State<TraineeScreen> {
  List<Widget> _buildExercises(TraineeEvent event) {
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
                context.read<EventProvider>().removeExercise(event, exercise.id);
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
    final userId = context.read<UserProvider>().id;
    return FutureBuilder(
        future: context.read<EventProvider>().fetchEventsByUserId(userId),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          final sortedEvents = weekDays.map((day) {
            return context.watch<EventProvider>().events.firstWhere((element) => element.day == day);
          });

          return MainScreen(
            child: Container(
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
                                          event
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
            )
          );
        }
    );
  }
}
