import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:flutter_app/providers/exercises_provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

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

class ExercisesDropdown extends StatefulWidget {
  final Function onChangeCallback;

  const ExercisesDropdown({Key? key, required this.onChangeCallback})
      : super(key: key);

  @override
  State<ExercisesDropdown> createState() => _ExercisesDropdownState();
}

class _ExercisesDropdownState extends State<ExercisesDropdown> {
  // Exercise dropdownValue;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: context.read<ExercisesProvider>().fetchExercises(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          return isLoading ? const Center(child: CircularProgressIndicator()) : DropdownButton<Exercise>(
            value: context.watch<ExercisesProvider>().list.first,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.black),
            underline: Container(
              height: 2,
              color: Colors.blueAccent,
            ),
            onChanged: (Exercise? value) {
              // This is called when the user selects an item.
              // setState(() {
              //   dropdownValue = value!;
              // });

              if (value != null) {
                widget.onChangeCallback(value.id);
              }
            },
            items: context.watch<ExercisesProvider>().list.map((Exercise exercise) {
              return DropdownMenuItem<Exercise>(
                value: exercise,
                child: Text(exercise.name),
              );
            }).toList(),
          );
        });
  }
}

class MainScreen extends StatefulWidget {
  final Function child;

  const MainScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<dynamic> _days = [];
  late int _currentMonth;
  late int _currentYear;

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
            context.read<EventProvider>().fetchUsersEventsByDate(userId, _days.first, _days.last),
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
                                final name = await openDialog();

                                if (name == null || name.isEmpty) return;
                              },
                            ))
                          ],
                        ),
                      );
                      ;
                    }).toList(),
                  )),
                ),
              )
              // body: widget.child(_tabController, _days.length),
              );
        });
  }

  Future<String?> openDialog() => showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Enter name for the schedule'),
            content: ExercisesDropdown(
              onChangeCallback: (id) {
                print(id);
              },
            ),
            actions: [
              TextButton(child: const Text('OK'), onPressed: submitName)
            ],
          ));

  void submitName() {
    // Navigator.of(context).pop(scheduleNameController.text);
    // scheduleNameController.clear();
  }
}
