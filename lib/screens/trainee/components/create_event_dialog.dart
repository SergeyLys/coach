import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter_app/assets/constants.dart';
import 'package:provider/provider.dart';
import './exercises_dropdown.dart';
import './week_day_dot.dart';

class CreateEventDialog extends StatefulWidget {
  final DateTime currentDate;
  // final List<int> disabledItems;
  final Function(int id, List<int> selectedDays, bool useSmartFiller) onSubmitCallback;
  const CreateEventDialog({Key? key, required this.onSubmitCallback, required this.currentDate}) : super(key: key);

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  late int selectedExerciseId;
  late List<int> selectedDays = [];
  bool useSmartFiller = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    selectedDays = [weekDaysShort.indexOf(DateFormat(DateFormat.ABBR_WEEKDAY).format(widget.currentDate))];
  }

  @override
  Widget build(BuildContext context) {
    // print(DateFormat().dateSymbols.WEEKDAYS);
    final eventsProvider = context.read<EventProvider>();
    final todayEvents = eventsProvider.extractEventsByDate(widget.currentDate);
    return AlertDialog(
      title: const Text('Enter name of the exercise you want to add'),
      content: Container(
        child: Column(
          children: [
            ExercisesDropdown(
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
                // controller: exerciseDropdownController,
                disabledItems: todayEvents.map((e) => e.exercise.id).toList(),
            ),
            const SizedBox(height: 15,),
            SwitchListTile(
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
      ),
      actions: [
        TextButton(child: const Text('OK'), onPressed: () => widget.onSubmitCallback(selectedExerciseId, selectedDays, useSmartFiller))
      ],
    );
  }
}