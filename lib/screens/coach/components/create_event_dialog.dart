import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/domains/gym_event_coach.dart';
import 'package:flutter_app/domains/gym_event_trainee.dart';
import 'package:flutter_app/providers/trainee-event_provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter_app/assets/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/common_widgets/week_day_dot.dart';

import '../../../providers/coach-event_provider.dart';

class ConfigureCoachEventDialog extends StatefulWidget {
  final String title;
  final DateTime currentDate;
  final Function(CoachEvent? event, DateTime start, DateTime end, List<String> selectedDays, bool useSmartFiller, String assigneeEmail) onSubmitCallback;
  final TimeOfDay startTime;
  // final TimeOfDay? endTime;
  // final List<int>? selectedDays;
  // final bool? useSmartFiller;
  final CoachEvent? event;
  const ConfigureCoachEventDialog({Key? key,
    required this.onSubmitCallback,
    required this.currentDate,
    required this.title,
    required this.startTime,
    // this.endTime,
    // this.selectedDays,
    // this.useSmartFiller,
    this.event,
  }) : super(key: key);

  @override
  State<ConfigureCoachEventDialog> createState() => _ConfigureCoachEventDialogState();
}

class _ConfigureCoachEventDialogState extends State<ConfigureCoachEventDialog> {
  late List<int> _selectedDays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  final assigneeNameController = TextEditingController();
  late bool _useSmartFiller;
  late String? _errorText;

  @override
  void initState() {
    super.initState();

    _startTime = widget.startTime;
    _errorText = null;

    if (widget.event != null) {
      _endTime = TimeOfDay(hour: DateTime.parse(widget.event!.endDate).toLocal().hour, minute: DateTime.parse(widget.event!.endDate).toLocal().minute);
      _selectedDays = widget.event!.repeatDays.map((e) => weekDaysShort.indexOf(e)).toList();
      _useSmartFiller = widget.event!.smartFiller;
      assigneeNameController.text = widget.event!.assignee.email;
    } else {
      _endTime = TimeOfDay(hour: widget.startTime.hour + 1, minute: 0);
      _selectedDays = [weekDaysShort.indexOf(DateFormat(DateFormat.ABBR_WEEKDAY).format(widget.currentDate))];
      _useSmartFiller = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startHours = _startTime.hour.toString().padLeft(2, '0');
    final startMinutes = _startTime.minute.toString().padLeft(2, '0');
    final endHours = _endTime.hour.toString().padLeft(2, '0');
    final endMinutes = _endTime.minute.toString().padLeft(2, '0');
    return AlertDialog(
      title: Text(widget.title),
      content: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start time: ${startHours}:${startMinutes}'),
                ElevatedButton(onPressed: () async {
                  TimeOfDay? newTime = await showTimePicker(context: context, initialTime: _startTime);

                  if (newTime == null) return;

                  setState(() {
                    _startTime = newTime;
                  });
                }, child: Text('Change')),
              ],
            ),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('End time: ${endHours}:${endMinutes}'),
                ElevatedButton(onPressed: () async {
                  TimeOfDay? newTime = await showTimePicker(context: context, initialTime: _startTime);

                  if (newTime == null) return;

                  setState(() {
                    _endTime = newTime;
                  });
                }, child: Text('Change')),
              ],
            ),
            const SizedBox(height: 15,),
            SwitchListTile(
              title: const Text('Use smart filler'),
              value: _useSmartFiller,
              onChanged: (bool value) {
                setState(() {
                  _useSmartFiller = value;
                });
              },
            ),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDaysShort.map((e) =>
                  WeekDayDot(
                    disabled: !_useSmartFiller,
                    isActive: _selectedDays.contains(weekDaysShort.indexOf(e)),
                    day: e,
                    onTap: (String value) {
                      if (value == DateFormat(DateFormat.ABBR_WEEKDAY).format(widget.currentDate)) {
                        return;
                      }

                      if (_selectedDays.contains(weekDaysShort.indexOf(value))) {
                        setState(() {
                          _selectedDays.removeWhere((element) => element == weekDaysShort.indexOf(value));
                        });
                      } else {
                        setState(() {
                          _selectedDays.add(weekDaysShort.indexOf(value));
                        });
                      }
                    },
                  )
              ).toList(),
            ),
            const SizedBox(height: 15,),
            TextField(
              controller: assigneeNameController,
              autofocus: true,
              decoration: InputDecoration(
                  hintText: 'Enter trainee email',
                errorText: _errorText,
                errorStyle: TextStyle(color: Colors.red)
              ),
              onChanged: (String value) {
                if (_errorText != null && _errorText!.isNotEmpty) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            child: Visibility(child: context.read<CoachEventProvider>().isCreatingLoading ? const CircularProgressIndicator() : const Text('OK')),
            onPressed: () async {
              if (assigneeNameController.text.isEmpty) {
                setState(() {
                  _errorText = 'Required';
                });
                return;
              }

              final startDate = widget.currentDate.add(Duration(hours: _startTime.hour, minutes: _startTime.minute));
              final endDate = widget.currentDate.add(Duration(hours: _endTime.hour, minutes: _endTime.minute));
              final List<String> selectedDays = _selectedDays.map<String>((e) => weekDaysShort[e]).toList();

              try {
                widget.onSubmitCallback(widget.event, startDate, endDate, selectedDays, _useSmartFiller, assigneeNameController.text);
              } catch(e) {
                if ((e as Map)['message'] != null) {
                  setState(() {
                    _errorText = e['message'];
                  });
                }
              }
            }
        ),
      ],
    );
  }
}