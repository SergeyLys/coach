import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:flutter_app/providers/exercises_provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

import 'exercises_dropdown.dart';

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

    if (to != null && currentDate.isAtSameMomentAs(to)) {
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
  late int _currentMonth;
  late int _currentYear;

  late int selectedExerciseId;

  @override
  void initState() {
    super.initState();

    final today = getToday();
    final days = getDaysForPeriod(today['month'], today['year'], null, null);

    _days = days;
    _currentMonth = today['month'];
    _currentYear = today['year'];
    _tabController = TabController(
        length: days.length,
        vsync: this,
        initialIndex: _days
            .indexWhere((element) => element.isAtSameMomentAs(today['date'])));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat.yMMMEd().format(DateTime.now());

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        late int month;
        late int year;

        final generateNextMonth = _tabController.index >= _days.length - 5;
        final generatePrevMonth = _tabController.index <= 5;

        if (generateNextMonth) {
          month = _currentMonth == 12 ? 1 : _currentMonth + 1;
          year = _currentMonth == 12 ? _currentYear + 1 : _currentYear;
        }

        if (generatePrevMonth) {
          month = _currentMonth == 1 ? 12 : _currentMonth - 1;
          year = _currentMonth == 1 ? _currentYear - 1 : _currentYear;
        }

        if (generateNextMonth || generatePrevMonth) {
          final days = getDaysForPeriod(month, year, null, null);
          final currentDay = _days[_tabController.index];

          setState(() {
            _days = [..._days, ...days];
            _currentMonth = month;
            _currentYear = year;
            _tabController = TabController(
                length: _days.length,
                vsync: this,
                initialIndex: _days.indexWhere(
                        (element) => element.isAtSameMomentAs(currentDay)));
          });
        }
      }
    });
    final userId = context.read<UserProvider>().id;

    // print(_days);

    return FutureBuilder(
        future:
        context.read<EventProvider>().fetchUsersEventsByDate(userId, _days),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
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
                          element.isAtSameMomentAs(today['date'])));
                    },
                    child: Text('$displayDate'),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelPadding:
                  EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 10),
                  tabs:
                  _days.map<Widget>((day) => Text(day.toString())).toList(),
                ),
              ),
              body: Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Container(
                  child: Center(
                      child: TabBarView(
                        controller: _tabController,
                        children: _days.map<Widget>((date) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 15, top: 15),
                            child: ListView(
                              children: [
                                // ..._buildExercises(event),
                                Text(date.toString()),
                                Center(
                                    child: TextButton(
                                      child: Text("Add exercise"),
                                      onPressed: () async {
                                        final exerciseId = await openDialog();

                                        if (exerciseId == null) return;

                                        context.read<EventProvider>().createEventFromCatalog(exerciseId);
                                      },
                                    ))
                              ],
                            ),
                          );
                        }).toList(),
                      )),
                ),
              )
          );
        });
  }

  Future<int?> openDialog() => showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter name for the schedule'),
        content: ExercisesDropdown(
          onChangeCallback: (id) {
            setState(() {
              selectedExerciseId = id;
            });
          },
        ),
        actions: [
          TextButton(child: const Text('OK'), onPressed: submitSelectedExercise)
        ],
      ));

  void submitSelectedExercise() {
    Navigator.of(context).pop(selectedExerciseId);
  }
}
