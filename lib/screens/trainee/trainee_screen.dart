import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/common_widgets/main_screen.dart';
import 'package:flutter_app/providers/trainee-event_provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/screens/trainee/components/event_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:flutter_app/domains/gym_event_trainee.dart';
import 'package:collection/collection.dart';
import 'package:flutter_app/domains/sets.dart';
import './components/create_event_dialog.dart';
import './trainee_screen_arguments.dart';

class TraineeScreen extends StatefulWidget {
  static const routeName = '/trainee-screen';

  const TraineeScreen({Key? key}) : super(key: key);

  @override
  State<TraineeScreen> createState() => _TraineeScreenState();
}

class _TraineeScreenState extends State<TraineeScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final TraineeScreenArguments? args = ModalRoute.of(context)!.settings.arguments as TraineeScreenArguments?;
    final userId = args?.userId ?? context.read<UserProvider>().id;

    return MainScreen(
        isLoading: context.watch<TraineeEventProvider>().isLoading,
        onFetchDays: (DateTime start, DateTime end) => context.read<TraineeEventProvider>().fetchUsersEventsByDate(userId, start, end),
        onPostFrameCallback: (DateTime start, DateTime end) => Provider.of<TraineeEventProvider>(context, listen: false).fetchUsersEventsByDate(userId, start, end),
        child: (DateTime date, double offset) {
          return Consumer<TraineeEventProvider>(
              builder: (context, provider, child) {
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

                                  provider.createEventFromCatalog(data['id'], date, selectedDays, data['useSmartFiller'], userId);
                                },
                              )
                          )
                        ],
                      ),
                    )
                );
              }
          );
        }
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







