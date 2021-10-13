import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_app/providers/gym_event_provider.dart';
import 'package:provider/src/provider.dart';

class ScheduleDetail extends StatefulWidget {
  GymEvent event;

  ScheduleDetail({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<ScheduleDetail> createState() => _ScheduleDetailState();
}

class _ScheduleDetailState extends State<ScheduleDetail> {

  void _handleAddRow() {
    context.read<GymEventProvider>().addExercise(
        widget.event.day, Exercise(
        id: Random().nextInt(9999999),
        name: '',
        sets: [Exercise.blankSet]
    ));
  }

  Widget _buildRow(Exercise exercise) {
    return Stack(
      key: GlobalKey(),
      children: [
        Container(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          margin: EdgeInsets.only(bottom: 15),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Exercise"),
                initialValue: exercise.name,
                onChanged: (value) {
                  context.read<GymEventProvider>().setExerciseName(exercise, value);
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
                  itemCount: exercise.sets.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    print('$index ${exercise.sets[index]}');
                    return Row(
                      children: [
                        Container(
                          width: 30,
                          child: TextFormField(
                            style: TextStyle(fontSize: 14),
                            initialValue: exercise.sets[index]['w'].toString(),
                            decoration: InputDecoration(
                              label: Text("Weight", style: TextStyle(fontSize: 10)),
                            ),
                            onChanged: (value) {
                              context.read<GymEventProvider>().editExerciseSet(exercise, index, 'w', int.parse(value));
                            },
                          ),
                        ),
                        Container(
                          width: 30,
                          child: TextFormField(
                            style: TextStyle(fontSize: 14),
                            initialValue: exercise.sets[index]['r'].toString(),
                            decoration: InputDecoration(
                              label: Text("Reps", style: TextStyle(fontSize: 10)),
                            ),
                            onChanged: (value) {
                              context.read<GymEventProvider>().editExerciseSet(exercise, index, 'r', int.parse(value));
                            },
                          ),
                        ),
                        if (index == exercise.sets.length - 1) Container(
                            margin: EdgeInsets.only(top: 10),
                            child: IconButton(
                                onPressed: () {
                                  context.read<GymEventProvider>().addEmptySet(widget.event.day, exercise.id);
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
              context.read<GymEventProvider>().removeExercise(widget.event, exercise.id);
            },
            icon: Icon(Icons.close),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDetails() {
    return widget.event.exercises.map<Widget>((row) => _buildRow(row)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildDetails(),
          Center(
              child: TextButton(
                child: Text("Add exercise"),
                onPressed: _handleAddRow,
              )),
        ],
      ),
    );
  }
}