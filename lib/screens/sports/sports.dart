import 'package:flutter/material.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/providers/schedule_provider.dart';
import 'package:flutter_app/screens/sports/schedule_constructor.dart';
import 'package:flutter_app/screens/sports/stats.dart';
import 'package:provider/src/provider.dart';

class Sports extends StatefulWidget {
  const Sports({Key? key}) : super(key: key);

  @override
  _SportsState createState() => _SportsState();
}

class _SportsState extends State<Sports> {
  int _selectedIndex = 0;

  static const List<Widget> _sportsPages = <Widget>[
    ScheduleConstructor(),
    Stats()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: context.read<ScheduleProvider>().fetchSchedules(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return DefaultTabController(
            initialIndex: weekDays.indexOf(context.read<ScheduleProvider>().today),
            length: weekDays.length,
            child: Scaffold(
              body: isLoading ? Center(child: CircularProgressIndicator()) : _sportsPages.elementAt(_selectedIndex),
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.schedule),
                    label: 'Workout',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.query_stats),
                    label: 'Stats',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.lightBlueAccent,
                onTap: _onItemTapped,
              ),
            ),
          );
        }
    );
  }
}
