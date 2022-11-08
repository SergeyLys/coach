import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/providers/event_provider.dart';
import 'package:flutter_app/screens/trainee/components/exercises_dropdown.dart';
import 'package:provider/provider.dart';

class WizardEvent extends StatefulWidget {
  final DateTime? selectedDate;
  final List<int>? disabledIds;
  const WizardEvent({Key? key, this.disabledIds, this.selectedDate}) : super(key: key);

  @override
  State<WizardEvent> createState() => _WizardEventState();
}

class _WizardEventState extends State<WizardEvent> {
  late int selectedExerciseId;

  @override
  Widget build(BuildContext context) {
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
              child: Text('Title'),
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: ExercisesDropdown(
              onChangeCallback: (int id) {
                setState(() {
                  selectedExerciseId = id;
                });
              },
              // disabledItems: events.map((e) => e.exercise.id).toList()
              disabledItems: widget.disabledIds ?? []
          ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          child: Center(
              child: GestureDetector(
                child: context.watch()<EventProvider>().isLoading ? CircularProgressIndicator() : Text('Create'),
                onTap: () {
                  // context.read<EventProvider>().createEventFromCatalog(selectedExerciseId, widget.selectedDate ?? DateTime.now());
                  print('tap');
                },
              )
          ),
        )
      ),
    );
  }
}
