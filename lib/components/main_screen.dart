import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/providers/trainee-event_provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:flutter_app/assets/utils.dart';

class MainScreen extends StatefulWidget {
  final bool isLoading;
  final void Function(DateTime start, DateTime end) onFetchDays;
  final void Function(DateTime start, DateTime end) onPostFrameCallback;
  final Function child;

  const MainScreen(
      {Key? key, required this.isLoading, required this.onFetchDays, required this.child, required this.onPostFrameCallback})
      : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final int daysOffset = 15;
  late TabController _tabController;
  late List<dynamic> _days = [];
  GlobalKey containerKey = GlobalKey();
  late double _topOffset = 0;

  @override
  void initState() {
    super.initState();

    final today = getToday();
    final days = getDaysForPeriod(today['month'], today['year'], null, null);
    late int nextYear;
    late int nextMonth;
    final buffer = [];

    final int daysInMonth = DateUtils.getDaysInMonth(
        today['year'], today['month']);
    final bool shouldAddNextMonth = today['date'].day >=
        daysInMonth - daysOffset;
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
            .indexWhere((element) =>
            DateUtils.isSameDay(element, today['date'])));
    _tabController.addListener(handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      RenderObject? box = containerKey.currentContext?.findRenderObject();
      Offset position = (box as RenderBox).localToGlobal(Offset.zero);
      double y = position.dy;

      setState(() {
        _topOffset = y;
      });
      widget.onPostFrameCallback(_days.first, _days.last);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final int currentMonth = _days[_tabController.index].month;
      final int currentYear = _days[_tabController.index].year;
      final generateNextMonth = _tabController.index >=
          _days.length - daysOffset;
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

        widget.onFetchDays(days.first, days.last);

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
                itemBuilder: (BuildContext context) =>
                <PopupMenuEntry>[
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
          bottom: widget.isLoading ? PreferredSize(
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
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(DateFormat('dd-MM-yyyy').format(day)),)
            ).toList(),
          ),
        ),
        body: Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Container(
                key: containerKey,
                child: Center(
                    child: TabBarView(
                        controller: _tabController,
                        children: _days.map<Widget>((date) => widget.child(date, _topOffset)).toList()
                    )
                )
            )
        )
    );
  }
}







