import 'package:flutter/material.dart';
import 'package:flutter_app/domains/schedule.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:flutter_app/providers/schedule_provider.dart';
import 'package:flutter_app/screens/trainee/trainee_screen.dart';
import 'package:provider/src/provider.dart';
import 'package:flutter_app/assets/constants.dart';

enum Menu { update, remove }

class ScheduleList extends StatefulWidget {
  const ScheduleList({Key? key}) : super(key: key);

  @override
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  late TextEditingController scheduleNameController;

  @override
  void initState() {
    super.initState();
    scheduleNameController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    scheduleNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<ScheduleProvider>().fetchSchedules(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final schedules = context.watch<ScheduleProvider>().schedules;

        return DefaultTabController(
          initialIndex: weekDays.indexOf(context.read<EventProvider>().today),
          length: weekDays.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Center(
                child: Text('Your schedules'),
              ),
            ),
            body: isLoading ? const Center(child: CircularProgressIndicator()) : Container(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Column(
                children: [
                  ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    children: schedules.map((Schedule item) => ListTile(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TraineeScreen(),
                            ),
                          )
                        },
                        onLongPress: () {
                          print('long');
                        },
                        title: Text(item.name),
                        trailing: PopupMenuButton<Menu>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (menuItem) async {
                            switch(menuItem) {
                              case Menu.update: {
                                scheduleNameController.text = item.name;

                                final name = await openDialog();

                                if (name == null || name.isEmpty) return;

                                context.read<ScheduleProvider>().updateSchedule(item.id, name);
                              }
                              break;
                              case Menu.remove: {
                                context.read<ScheduleProvider>().deleteSchedule(item.id);
                              }
                              break;
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<Menu>(
                              value: Menu.update,
                              child: Text('Rename'),
                            ),
                            const PopupMenuItem<Menu>(
                              value: Menu.remove,
                              child: Text('Remove'),
                            ),
                          ])

                    )).toList(),
                  ),
                  Center(
                      child: TextButton(
                        child: const Icon(Icons.add_rounded, size: 100),
                        onPressed: () async {
                          final name = await openDialog();

                          if (name == null || name.isEmpty) return;

                          context.read<ScheduleProvider>().createSchedule(name, weekDays);
                        },
                      )
                  )
                ]
              )
            )
          ),
        );
      }
    );
  }

  Future<String?> openDialog() => showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enter name for the schedule'),
      content: TextField(
        controller: scheduleNameController,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Enter name'),
        onSubmitted: (_) => submitName(),
      ),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: submitName
        )
      ],
    )
  );

  void submitName() {
    Navigator.of(context).pop(scheduleNameController.text);
    scheduleNameController.clear();
  }
}
