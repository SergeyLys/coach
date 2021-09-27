import 'package:flutter/material.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/providers/gym_event_provider.dart';
import 'package:provider/src/provider.dart';

class GymEventDetail extends StatefulWidget {
  Function onChangeDetails;

  GymEvent event;

  GymEventDetail({
    Key? key,
    required this.event,
    required this.onChangeDetails,
  }) : super(key: key);

  @override
  State<GymEventDetail> createState() => _GymEventDetailState();
}

class _GymEventDetailState extends State<GymEventDetail> {

  void _handleAddRow() {
    context.read<GymEventProvider>().addExercise(
        widget.event.day, Exercise(
      name: '',
      sets: [Exercise.blankSet]
    ));
  }

  Widget _buildRow(Exercise exercise) {
    return Stack(
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
                  context.read<GymEventProvider>().setExerciseName(widget.event.day, exercise.id, value);
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
                    return Row(
                      children: [
                        Container(
                          width: 30,
                          child: TextFormField(
                            focusNode: FocusNode(),
                            style: TextStyle(fontSize: 14),
                            initialValue: exercise.sets[index]['w'].toString(),
                            decoration: InputDecoration(
                              label: Text("Weight", style: TextStyle(fontSize: 10)),
                            ),
                            onChanged: (value) {
                              // widget.onChangeDetails(value, widget.forDay);
                            },
                          ),
                        ),
                        Container(
                          width: 30,
                          child: TextFormField(
                            focusNode: FocusNode(),
                            style: TextStyle(fontSize: 14),
                            initialValue: exercise.sets[index]['r'].toString(),
                            decoration: InputDecoration(
                              label: Text("Reps", style: TextStyle(fontSize: 10)),
                            ),
                            onChanged: (value) {
                              // widget.onChangeDetails(value, widget.forDay);
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
              context.read<GymEventProvider>().removeExercise(widget.event.day, exercise.id);
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

class UserEventConstructor extends StatefulWidget {
  const UserEventConstructor({Key? key}) : super(key: key);

  @override
  _UserEventConstructorState createState() => _UserEventConstructorState();
}

class _UserEventConstructorState extends State<UserEventConstructor> {
  String eventType = 'Gym';
  Map<String, dynamic> eventDetails = {};

  void _handleChangeDetails(String value, String forDay) {
    eventDetails[forDay] = value;
  }

  Widget _buildEventDetails(GymEvent value) {
    switch (eventType) {
      case 'Gym':
        return GymEventDetail(
            key: GlobalKey(),
            event: value, onChangeDetails: _handleChangeDetails);
      default:
        return SizedBox.shrink();
    }
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
