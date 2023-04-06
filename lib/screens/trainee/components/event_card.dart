import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_app/domains/gym_event_trainee.dart';
import 'package:flutter_app/domains/sets.dart';

import 'SetsTextField.dart';

class EventCard extends StatefulWidget {
  final TraineeEvent event;
  final SetsModel currentSet;
  final void Function() onRemoveEvent;
  final void Function() onEditEvent;
  final void Function(List<RepsModel> reps) onSaveEvent;
  const EventCard({Key? key,
    required this.event,
    required this.currentSet,
    required this.onRemoveEvent,
    required this.onEditEvent,
    required this.onSaveEvent,
  }) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late List<RepsModel> _reps = [];
  late bool _isUnsaved = false;

  @override
  void initState() {
    super.initState();

    _reps = [...widget.currentSet.reps];
    _isUnsaved = widget.currentSet.isVirtual;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: ValueKey(widget.event.id),
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
                decoration: const InputDecoration(
                  labelText: "Exercise",
                ),
                initialValue: widget.event.exercise.name,
                readOnly: true,
              ),
              Container(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _reps.length,
                  separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final currentReps = _reps.lastWhere((element) => element.order == index+1);
                    return Row(
                      children: [
                        Container(
                            width: 40,
                            child: SetsTextField(
                              placeholder: "Weight",
                              initialValue: currentReps.weight != null ? currentReps.weight
                                  .toString() : '',
                              onChangeCallback: (String value) {
                                final val = value.isEmpty ? '0' : value;
                                final hasDigits = RegExp(r'^[0-9]+$').hasMatch(val);

                                if (!hasDigits) {
                                  return;
                                }

                                setState(() {
                                  currentReps.weight = int.parse(val);
                                  _isUnsaved = true;
                                });
                              },
                            )
                        ),
                        Container(
                            width: 40,
                            child:
                            SetsTextField(
                              placeholder: "Reps",
                              initialValue: currentReps.reps != null ? currentReps.reps.toString() : '',
                              onChangeCallback: (String value) {
                                final val = value.isEmpty ? '0' : value;
                                final hasDigits = RegExp(r'^[0-9]+$').hasMatch(val);

                                if (!hasDigits) {
                                  return;
                                }

                                setState(() {
                                  currentReps.reps = int.parse(val);
                                  _isUnsaved = true;
                                });
                              },
                            )
                        ),
                        if (index == _reps.length - 1) Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (_reps.length > 1) Container(
                                height: 20,
                                margin: const EdgeInsets.only(top: 0),
                                child: IconButton(
                                    iconSize: 20,
                                    onPressed: () {
                                      setState(() {
                                        _reps.removeLast();
                                        _isUnsaved = _reps.length != widget.currentSet.reps.length;
                                      });
                                    },
                                    icon: const Icon(Icons.remove)
                                )
                            ),
                            Container(
                                height: 20,
                                margin: const EdgeInsets.only(top: 0),
                                child: IconButton(
                                    iconSize: 20,
                                    onPressed: () {
                                      final RepsModel createdRep = RepsModel(weight: null, reps: null, order: _reps.length+1);
                                      setState(() {
                                        _reps.add(createdRep);
                                        _isUnsaved = _reps.length != widget.currentSet.reps.length;
                                      });
                                    },
                                    icon: const Icon(Icons.add)
                                )
                            )
                          ],
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (!widget.currentSet.isVirtual) Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            onPressed: widget.onRemoveEvent,
            icon: const Icon(Icons.close),
          ),
        ),
        Positioned(
          top: 0,
          right: widget.currentSet.isVirtual ? 0 : 35,
          child: IconButton(
              onPressed: widget.onEditEvent,
              icon: const Icon(Icons.edit, size: 25,)
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            onPressed: () {
              widget.onSaveEvent(_reps);
            },
            icon: _isUnsaved
                ? const Icon(Icons.check, size: 25, color: Colors.green,)
                : const Icon(Icons.check, size: 20, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
