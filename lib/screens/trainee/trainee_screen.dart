import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/screens/trainee/components/event_card.dart';
import 'package:flutter_app/screens/trainee/components/exercises_dropdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:flutter_app/domains/gym_event_trainee.dart';
import 'package:collection/collection.dart';

import 'package:flutter_app/domains/sets.dart';
import './components/create_event_dialog.dart';

const int daysOffset = 15;

List<dynamic> getDaysForPeriod(int month, int year, int? from, DateTime? to) {
  final List<dynamic> days = [];
  late int day = 1;

  if (from != null) {
    day += from - 1;
  }

  final DateTime startDate = DateTime(year, month, day);

  var currentDate = startDate;

  while (currentDate.month == month) {
    days.add(currentDate);

    if (to != null && DateUtils.isSameDay(currentDate, to)) {
      break;
    }

    currentDate = DateTime(year, month, currentDate.day + 1);
  }

  return days;
}

Map<String, dynamic> getToday() {
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;
  final date = DateTime(now.year, now.month, now.day);

  return {'month': currentMonth, 'year': currentYear, 'date': date};
}

class TraineeScreen extends StatefulWidget {
  const TraineeScreen({Key? key}) : super(key: key);

  @override
  State<TraineeScreen> createState() => _TraineeScreenState();
}

class _TraineeScreenState extends State<TraineeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<dynamic> _days = [];

  @override
  void initState() {
    super.initState();

    final today = getToday();
    final days = getDaysForPeriod(today['month'], today['year'], null, null);
    late int nextYear;
    late int nextMonth;
    final buffer = [];

    final int daysInMonth = DateUtils.getDaysInMonth(today['year'], today['month']);
    final bool shouldAddNextMonth = today['date'].day >= daysInMonth - daysOffset;
    final bool shouldAddPrevMonth = today['date'].day <= daysOffset;

    if (shouldAddNextMonth) {
      nextYear = today['year'];
      if (today['month'] == 12) {
        nextYear += 1;
        nextMonth = 1;
      } else {
        nextMonth = today['month'] + 1;
      }
      final nextDays = getDaysForPeriod(nextMonth, nextYear, null, null);

      buffer.addAll(nextDays);
    }

    if (shouldAddPrevMonth) {
      nextYear = today['year'];
      if (today['month'] == 1) {
        nextYear -= 1;
        nextMonth = 12;
      } else {
        nextMonth = today['month'] - 1;
      }
      final nextDays = getDaysForPeriod(nextMonth, nextYear, null, null);

      buffer.addAll(nextDays);
    }

    final result = [...days, ...buffer];

    result.sort((date1, date2) => date1.compareTo(date2));

    _days = result;
    _tabController = TabController(
        length: _days.length,
        vsync: this,
        initialIndex: _days
            .indexWhere((element) => DateUtils.isSameDay(element, today['date'])));
    _tabController.addListener(handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final userId = context.read<UserProvider>().id;
      Provider.of<EventProvider>(context, listen: false).fetchUsersEventsByDate(userId, _days.first, _days.last);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void handleTabChange() {
    final userId = context.read<UserProvider>().id;

    if (!_tabController.indexIsChanging) {
        final int currentMonth = _days[_tabController.index].month;
        final int currentYear = _days[_tabController.index].year;
        final generateNextMonth = _tabController.index >= _days.length - daysOffset;
        final generatePrevMonth = _tabController.index <= daysOffset;
        late int month;
        late int year;

        if (generateNextMonth) {
          month = currentMonth == 12 ? 1 : currentMonth + 1;
          year = currentMonth == 12 ? currentYear + 1 : currentYear;
        }

        if (generatePrevMonth) {
          month = currentMonth == 1 ? 12 : currentMonth - 1;
          year = currentMonth == 1 ? currentYear - 1 : currentYear;
        }

        if (generateNextMonth || generatePrevMonth) {
          final days = getDaysForPeriod(month, year, null, null);
          final currentDay = _days[_tabController.index];
          final result = [..._days, ...days];

          result.sort((date1, date2) => date1.compareTo(date2));

          final currentIndex = result.indexWhere(
                  (element) => DateUtils.isSameDay(element, currentDay));

          context.read<EventProvider>().fetchUsersEventsByDate(userId, days.first, days.last);

          setState(() {
            _days = result;
            _tabController = TabController(
              length: result.length,
              vsync: this,
              initialIndex: currentIndex,
            );
          });

          _tabController.addListener(handleTabChange);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat.yMMMEd().format(DateTime.now());

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            PopupMenuButton(
                onSelected: (item) {
                  print(item);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  const PopupMenuItem(
                    value: 0,
                    child: Text('Item 1'),
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Text('Item 2'),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text('Item 3'),
                  ),
                  const PopupMenuItem(
                    value: 3,
                    child: Text('Item 4'),
                  ),
                ]),
          ],
          title: Center(
            child: GestureDetector(
              onTap: () {
                final today = getToday();

                _tabController.animateTo(_days.indexWhere((element) =>
                    DateUtils.isSameDay(element, today['date'])));
              },
              child: Text('$displayDate'),
            ),
          ),
          bottom: context.watch<EventProvider>().isLoading ? PreferredSize(
              child: Container(
                height: 0.0,
              ),
              preferredSize: const Size.fromHeight(0.0)
          ) : TabBar(
            controller: _tabController,
            isScrollable: true,
            labelPadding:
            const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 10),
            tabs:
            _days.map<Widget>((day) =>
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(DateFormat('dd-MM-yyyy').format(day)),)
            ).toList(),
          ),
        ),
        body: Consumer<EventProvider>(
          builder: (context, provider, child) =>
              Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Container(
                  child: Center(
                      child: TabBarView(
                        controller: _tabController,
                        children: _days.map<Widget>((date) {
                          final events = provider.extractEventsByDate(date);
                          return Visibility(
                            visible: !provider.isLoading,
                            replacement: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15, top: 15),
                              child: ListView(
                                children: [
                                  ...events.map((event) {
                                    final currentSet = provider.extractSets(event, date);
                                    return EventCard(
                                      event: event,
                                      currentSet: currentSet,
                                      onRemoveEvent: () {
                                        provider.removeExercise(event, currentSet);
                                      },
                                      onEditEvent: () async {
                                        final data = await openEditExerciseDialog(event, date);

                                        if (data == null) return;

                                        final List<String> selectedDays = data['selectedDays'].map<String>((e) => weekDaysShort[e]).toList();
                                        final isDaysListEqual = const ListEquality().equals(selectedDays, event.repeatDays);
                                        final isSmartFillerChanged = event.smartFiller != data['useSmartFiller'];

                                        if (!isDaysListEqual || isSmartFillerChanged) {
                                          provider.saveEventConfig(event, selectedDays, data['useSmartFiller']);
                                        }
                                      },
                                      onSaveEvent: (List<RepsModel> reps) {
                                        provider.saveSets(event, currentSet, reps, date);
                                      }
                                    );
                                  }).toList(),
                                  Text('${date.toString()} ${DateFormat(DateFormat.ABBR_WEEKDAY).format(date)}'),
                                  Center(
                                      child: TextButton(
                                        child: Text("Add exercise"),
                                        onPressed: () async {
                                          final data = await openAddExerciseDialog(date);

                                          if (data!['id'] == null) return;

                                          final List<String> selectedDays = data['selectedDays'].map<String>((e) => weekDaysShort[e]).toList();

                                          provider.createEventFromCatalog(data['id'], date, selectedDays, data['useSmartFiller']);
                                        },
                                      ))
                                ],
                              ),
                            )
                          );
                        }).toList(),
                      )),
                ),
              ),


          ),
    );
  }

  Future<Map<String, dynamic>?> openEditExerciseDialog(TraineeEvent event, DateTime currentDate) => showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) {
        return ConfigureEventDialog(
            title: 'Update your ${event.exercise.name} configuration',
            event: event,
            currentDate: currentDate,
            onSubmitCallback: submitExercise,
        );
      });

  Future<Map<String, dynamic>?> openAddExerciseDialog(DateTime currentDate) => showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) {
        return ConfigureEventDialog(
          title: 'Enter name of the exercise you want to add',
          currentDate: currentDate,
          onSubmitCallback: submitExercise,
        );
      });

  void submitExercise(int id, List<int> selectedDays, bool useSmartFiller) {
    Navigator.of(context).pop({'id': id, 'selectedDays': selectedDays, 'useSmartFiller': useSmartFiller});
  }
}







