import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/domains/sets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/services/network_service.dart';
import 'package:flutter_app/domains/gym_event_trainee.dart';
import 'package:collection/collection.dart';

class TraineeEventProvider extends ChangeNotifier {
  final List<TraineeEvent> _events = [];
  List<TraineeEvent> get events => _events;

  final String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String get currentDate => _currentDate;

  final String _today = DateFormat.E().format(DateTime.now());
  String get today => _today;

  bool isLoading = false;

  List<TraineeEvent> parseTraineeEntities(List<dynamic> responseBody) => responseBody.map<TraineeEvent>((json) => TraineeEvent.fromJson(json)).toList();

  Future<void> saveEventConfig(TraineeEvent event, List<String> selectedDays, bool useSmartFiller) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await NetworkService().post(
          '$apiUrl/trainee-events/update',
          body: {
            'id': event.id,
            'repeatDays': selectedDays,
            'smartFiller': useSmartFiller
          }
      );

      event.smartFiller = response[0]['smartFiller'];
      event.repeatDays = List<String>.from(response[0]['repeatDays']);

      if (!event.smartFiller) {
        event.sets.removeWhere((element) => element.isVirtual);
      }

      isLoading = false;
      notifyListeners();
    } catch(e) {
      print('saveEventConfig error $e');
    }
  }

  Future<void> createEventFromCatalog(int exerciseId, DateTime date, List<String> selectedDays, bool useSmartFiller, int assigneeId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await NetworkService().post(
          '$apiUrl/trainee-events',
          body: {
            'exerciseID': exerciseId,
            'date': date.toString(),
            'repeatDays': selectedDays,
            'smartFiller': useSmartFiller,
            'assigneeId': assigneeId
          }
      );

      final result = TraineeEvent.fromJson(response);

      final overlap = _events.indexWhere((element) => element.id == result.id);

      if (overlap > -1) {
        _events[overlap] = result;
      } else {
        _events.add(result);
      }

      isLoading = false;
      notifyListeners();
    } catch(e) {
      print('createEventFromCatalog error $e');
    }
  }

  Future<void> fetchUsersEventsByDate(int userId, DateTime start, DateTime end) async {
    try {
      final bool shouldFetchEvents = _events.where((element) {
        final foundStartSets = element.sets.where((setModel) =>
          DateTime.parse(setModel.date).isAtSameMomentAs(start)
        );
        final foundEndSets = element.sets.where((setModel) =>
            DateTime.parse(setModel.date).isAtSameMomentAs(end)
        );
        return foundStartSets.isNotEmpty || foundEndSets.isNotEmpty;
      }).isEmpty;

      if (!shouldFetchEvents) {
        return;
      }

      isLoading = true;
      notifyListeners();

      final response = await NetworkService().get(
          '$apiUrl/trainee-events/by-user/$userId?from=${start.toString()}&to=${end.toString()}'
      );

      final List<TraineeEvent> result = response.map<TraineeEvent>((json) => TraineeEvent.fromJson(json)).toList();

      _events.addAll(result);

      isLoading = false;
      notifyListeners();
    } catch(e) {
      print('fetchUsersEventsByDate error $e');
    }
  }

  Future<void> saveSets(TraineeEvent event, SetsModel sets, List<RepsModel> newReps, DateTime date) async {
    try {
      isLoading = true;
      notifyListeners();
      final currentIndex = event.sets.indexOf(sets);
      var mergedSetsModel = sets;
      final mergedReps = [];
      final removedReps = [];

      if (sets.reps.length >= newReps.length) {
        mergedReps.addAll(newReps.mapIndexed((index, rep) {
          rep.id = sets.reps[index].id;
          return rep;
        }));
        removedReps.addAll(
          sets.reps.sublist(newReps.length).map((e) => e.id).toList()
        );
      }

      if (newReps.length > sets.reps.length) {
        final trimmed = newReps.sublist(sets.reps.length);
        mergedReps.addAll(
            [
              ...sets.reps.mapIndexed((index, rep) {
                rep.reps = newReps[index].reps;
                rep.weight = newReps[index].weight;
                return rep;
              }),
              ...trimmed
            ]
        );
      }

      if (sets.isVirtual) {
        final response = await NetworkService().post(
            '$apiUrl/sets/create',
            body: {
              'date': date.toString(),
              'eventID': event.id
            }
        );
        response['reps'] = [];
        final result = SetsModel.fromJson(response);
        mergedSetsModel = result;
        mergedSetsModel.reps = mergedReps.map((e) => RepsModel(weight: e.weight, reps: e.reps, order: e.order)).toList();
      }

      final response = await NetworkService().post(
          '$apiUrl/reps/save',
          body: {
            'items': mergedReps.map((item) => {
              'setsID': mergedSetsModel.id,
              'id': item.id,
              'weight': item.weight,
              'reps': item.reps,
              'order': item.order,
            }).toList(),
            'removed': removedReps.toList()
          }
      );
      mergedSetsModel.reps = response.map<RepsModel>((element) => RepsModel.fromJson(element)).toList();
      mergedSetsModel.isChanged = false;
      mergedSetsModel.isVirtual = false;
      event.sets.removeAt(currentIndex);
      event.sets.insert(currentIndex, mergedSetsModel);
      isLoading = false;
      notifyListeners();
    } catch(e) {
      print('saveEvent error $e');
    }
  }

  Future<void> removeExercise(TraineeEvent event, SetsModel sets) async {
    try {
      isLoading = true;
      notifyListeners();

      if (sets.isVirtual) {
        sets.isDeactivated = true;
        isLoading = false;
        notifyListeners();
        return;
      }

      final removed = await NetworkService().post(
          '$apiUrl/sets/destroy',
          body: {
            'eventID': event.id,
            'id': sets.id
          }
      );

      event.sets.removeWhere((element) => element.id == removed['sets']);
      
      if (removed['event'] != null) {
        events.removeWhere((element) => element.id == removed['event']);
      }

      isLoading = false;
      notifyListeners();
    } catch(e) {
      print('removeExercise error $e');
    }
  }

  TraineeEvent getEventById(int id) {
    return events.firstWhere((element) => element.id == id);
  }

  TraineeEvent? getEventByExerciseId(int id) {
    if (events.isEmpty) return null;
    return events.cast<TraineeEvent?>().firstWhere((element) => element?.exercise.id == id, orElse: () => null);
  }

  List<TraineeEvent> extractEventsByDate(DateTime date) {
    final currentEvents = events.where((element) {

      element.sets.sort((a, b) => a.date.compareTo(b.date));

      final setsForCurrentDate = element.sets.where((setModel) {
        return DateUtils.isSameDay(DateTime.parse(setModel.date).toLocal(), date);
      });

      if (element.smartFiller) {
        final isDayMatched = element.repeatDays.contains(DateFormat(DateFormat.ABBR_WEEKDAY).format(date));
        final isAfterDate = DateTime.parse(element.sets.first.date).isBefore(date);
        final isSameDate = DateUtils.isSameDay(DateTime.parse(element.sets.first.date).toLocal(), date);
        final isAfterOrSame = isAfterDate || isSameDate;

        if (setsForCurrentDate.isNotEmpty) {
          return (isDayMatched && isAfterOrSame) && setsForCurrentDate.where((element) => element.isDeactivated).isEmpty;
        }

        return (isDayMatched && isAfterOrSame);
      }

      return setsForCurrentDate.isNotEmpty;
    }).toList();

    return currentEvents;
  }

  SetsModel extractSets(TraineeEvent event, DateTime date) {

    event.sets.sort((a, b) => a.date.compareTo(b.date));

    final currentSets = event.sets.cast<SetsModel?>().firstWhere((element) =>
        DateUtils.isSameDay(DateTime.parse(element?.date as String).toLocal(), date),
        orElse: () => null
    );

    if (currentSets != null && (currentSets.isChanged || !currentSets.isVirtual)) {
      return currentSets;
    }

    final lastCompleted = event.sets.lastWhere(
        (element) {
          final lastCompletedReps = element.reps.cast<RepsModel?>().lastWhere((rep) => rep?.reps != null && rep?.weight != null, orElse: () => null);

          return !element.isVirtual && lastCompletedReps != null;
        },
        orElse: () => event.sets.last
    );

    if (currentSets == null) {
      final newSets = SetsModel(
          date: date.toString(),
          reps: lastCompleted.reps
              .where((element) => element.id != null)
              .map((e) => RepsModel(weight: e.weight, reps: e.reps, order: e.order)).toList()
      );
      newSets.isVirtual = true;
      newSets.isChanged = false;
      event.sets.add(newSets);
      return newSets;
    }

    final isLatestIsAfterThanCurrent = DateTime.parse(currentSets.date).isAfter(DateTime.parse(lastCompleted.date));

    if (isLatestIsAfterThanCurrent && currentSets.isVirtual) {
      currentSets.reps = lastCompleted.reps
          .where((element) => element.id != null)
          .map((e) => RepsModel(weight: e.weight, reps: e.reps, order: e.order)).toList();
    }

    return currentSets;
  }
}