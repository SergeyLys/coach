import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat.yMMMEd().format(DateTime.now());

    return DefaultTabController(
        initialIndex: weekDays.indexOf(context
            .read<EventProvider>()
            .today),
        length: weekDays.length,
        child: Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                // This button presents popup menu items.
                PopupMenuButton(
                  // Callback that sets the selected popup menu item.
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
                child: Text('$displayDate'),
              ),
              bottom: TabBar(
                labelPadding: EdgeInsets.only(
                    left: 0, right: 0, top: 0, bottom: 10),
                tabs: weekDays.map<Widget>((day) => Text(day)).toList(),
              ),
            ),
            body: widget.child
        )
    );
  }
}

