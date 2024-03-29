import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/domains/gym_event_trainee.dart';
import 'package:flutter_app/providers/trainee-event_provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter_app/assets/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/screens/exercise-wizard/wizard-screen.dart';
import './exercises_dropdown.dart';
import 'package:flutter_app/common_widgets/week_day_dot.dart';

class ConfigureEventDialog extends StatefulWidget {
  final String title;
  final TraineeEvent? event;
  final DateTime currentDate;
  final Function(int id, List<int> selectedDays, bool useSmartFiller) onSubmitCallback;
  const ConfigureEventDialog({Key? key,
    required this.onSubmitCallback,
    required this.currentDate,
    this.event,
    required this.title
  }) : super(key: key);

  @override
  State<ConfigureEventDialog> createState() => _ConfigureEventDialogState();
}

class _ConfigureEventDialogState extends State<ConfigureEventDialog> {
  late List<int> selectedDays = [];
  late int selectedExerciseId;
  bool useSmartFiller = false;

  @override
  void initState() {
    super.initState();

    if (widget.event != null) {
      useSmartFiller = widget.event!.smartFiller;
      selectedDays = widget.event!.repeatDays.map((day) => weekDaysShort.indexOf(day)).toList();
    } else {
      selectedDays = [weekDaysShort.indexOf(DateFormat(DateFormat.ABBR_WEEKDAY).format(widget.currentDate))];
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.read<TraineeEventProvider>();
    final todayEvents = eventsProvider.extractEventsByDate(widget.currentDate);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        children: [
          ExercisesDropdown(
            selectedItem: widget.event?.exercise,
            onChangeCallback: (int id) {
              final foundEvent = eventsProvider.getEventByExerciseId(id);
              final buffer = [...selectedDays];

              if (foundEvent != null) {
                buffer.addAll(foundEvent.repeatDays.map((el) => weekDaysShort.indexOf(el)).toList());
              }

              setState(() {
                selectedExerciseId = id;
                selectedDays = buffer.toSet().toList();
              });
            },
            disabledItems: todayEvents.map((e) => e.exercise.id).toList(),
          ),
          const SizedBox(height: 15,),
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  style: TextStyle(fontSize: 14.0),
                  text: "Haven't found anything? "
                ),
                TextSpan(
                    text: 'Create exercise',
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, ExerciseWizard.routeName);
                }),
              ],
            ),
          ),
          const SizedBox(height: 15,),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Use smart filler'),
            value: useSmartFiller,
            onChanged: (bool value) {
              setState(() {
                useSmartFiller = value;
              });
            },
          ),
          const SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDaysShort.map((e) =>
                WeekDayDot(
                  disabled: !useSmartFiller,
                  isActive: selectedDays.contains(weekDaysShort.indexOf(e)),
                  day: e,
                  onTap: (String value) {
                    if (value == DateFormat(DateFormat.ABBR_WEEKDAY).format(widget.currentDate)) {
                      return;
                    }

                    if (selectedDays.contains(weekDaysShort.indexOf(value))) {
                      setState(() {
                        selectedDays.removeWhere((element) => element == weekDaysShort.indexOf(value));
                      });
                    } else {
                      setState(() {
                        selectedDays.add(weekDaysShort.indexOf(value));
                      });
                    }
                  },
                )
            ).toList(),
          )
        ],
      ),
      actions: [
        TextButton(child: const Text('OK'), onPressed: () {
          final id = widget.event != null ? widget.event!.id : selectedExerciseId;
          widget.onSubmitCallback(id, selectedDays, useSmartFiller);
        }),
      ],
    );
  }
}