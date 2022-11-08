import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/domains/sets.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/services/network_service.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/domains/gym_event_trainee.dart';
import 'package:flutter_app/domains/schedule.dart';

class EventProvider extends ChangeNotifier {
  List<TraineeEvent> _events = [];
  List<TraineeEvent> get events => _events;

  final String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String get currentDate => _currentDate;

  final String _today = DateFormat.E().format(DateTime.now());
  String get today => _today;

  bool isLoading = false;


  TraineeEvent getEventById(int id) {
    return events.firstWhere((element) => element.id == id);
  }

  TraineeEvent? getEventByExerciseId(int id) {
    if (events.isEmpty) return null;
    return events.cast<TraineeEvent?>().firstWhere((element) => element?.exercise.id == id, orElse: () => null);
  }

  List<TraineeEvent> parseTraineeEntities(List<dynamic> responseBody) => responseBody.map<TraineeEvent>((json) => TraineeEvent.fromJson(json)).toList();

  Future<void> fetchEventsByUserId(int userId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await NetworkService().get(
          '$apiUrl/events/by-user/$userId'
      );

      isLoading = false;

      print(response);
      // final result = parseTraineeEntities(response);
      //
      // _events = result;
      notifyListeners();
    } catch(e) {
      print('fetchEvents error $e');
    }
  }

  Future<void> createEventFromCatalog(int exerciseId, DateTime date, List<String> selectedDays, bool useSmartFiller) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await NetworkService().post(
          '$apiUrl/events',
          body: {
            'exerciseID': exerciseId,
            'date': date.toString(),
            'repeatDays': selectedDays,
            'smartFiller': useSmartFiller
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
          '$apiUrl/events/by-user/$userId?from=${start.toString()}&to=${end.toString()}'
      );

      final List<TraineeEvent> result = response.map<TraineeEvent>((json) => TraineeEvent.fromJson(json)).toList();

      _events = result;

      isLoading = false;
      notifyListeners();
    } catch(e) {
      print('fetchUsersEventsByDate error $e');
    }
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

    final lastCompleted = event.sets.lastWhere((element) => element.reps.last.reps != null && element.reps.last.weight != null);

    if (currentSets == null) {
      final newSets = SetsModel(
          date: date.toString(),
          reps: lastCompleted.reps.map((el) =>
              RepsModel(weight: el.weight, reps: el.reps, order: el.order)
          ).toList()
      );
      newSets.isVirtual = true;
      event.sets.add(newSets);
      return newSets;
    }

    // print('$date '
    //     'currentSets.id: ${currentSets.id} '
    //     'currentSets.reps.first.id: ${currentSets.reps.first.id} '
    //     'reps: ${currentSets.reps.first.reps} isDeactivated: ${currentSets.isDeactivated}');

    if (DateTime.parse(currentSets.date).isAfter(DateTime.parse(lastCompleted.date))) {
      currentSets.reps = lastCompleted.reps.map((e) => RepsModel(weight: e.weight, reps: e.reps, order: e.order)).toList();
    }

    currentSets.reps.sort((a, b) => a.order.compareTo(b.order));

    return currentSets;
  }

  void addSet(SetsModel sets) {
    try {
      final RepsModel createdRep = RepsModel(weight: null, reps: null, order: sets.reps.length+1);
      sets.reps.add(createdRep);
      notifyListeners();
    } catch(e) {
      print('addSet error $e');
    }
  }

  Future<void> removeSet(SetsModel sets) async {
    try {
      final idForDelete = sets.reps.last.id;

      sets.reps.removeLast();
      notifyListeners();

      if (idForDelete == null) return;

      isLoading = true;
      notifyListeners();

      await NetworkService().delete(
          '$apiUrl/reps/$idForDelete',
      );

      isLoading = false;
      notifyListeners();
    } catch(e) {
      print('removeSet error $e');
    }
  }

  void editSetWeight(SetsModel sets, int index, int value) {
    try {
      sets.reps[index].weight = value;
      sets.isChanged = true;
      notifyListeners();
    } catch(e) {
      print('editSetWeight error $e');
    }
  }

  void editSetReps(SetsModel sets, int index, int value) {
    try {
      sets.reps[index].reps = value;
      sets.isChanged = true;
      notifyListeners();
    } catch(e) {
      print('editSetWeight error $e');
    }
  }

  Future<void> saveChanges(TraineeEvent event, SetsModel sets, DateTime date) async {
    try {
      isLoading = true;
      notifyListeners();
      final currentIndex = event.sets.indexOf(sets);
      var mergedSetsModel = sets;


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
        mergedSetsModel.reps = sets.reps.map((e) => RepsModel(weight: e.weight, reps: e.reps, order: e.order)).toList();
      }
      //
      final response = await NetworkService().post(
          '$apiUrl/reps/save',
          body: {
            'items': mergedSetsModel.reps.map((item) => {
              'setsID': mergedSetsModel.id,
              'id': item.id,
              'weight': item.weight,
              'reps': item.reps,
              'order': item.order,
            }).toList()
          }
      );
      final List<RepsModel> result = response.map<RepsModel>((element) => RepsModel.fromJson(element)).toList();
      mergedSetsModel.reps = result;
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
        print(sets.isVirtual);
        print(sets.isDeactivated);
        notifyListeners();
        return;
      }

      await NetworkService().post(
        '$apiUrl/sets/destroy',
        body: {
            'eventID': event.id,
            'id': sets.id
        }
      );

      event.sets.removeWhere((element) => element.id == sets.id);

      isLoading = false;
      notifyListeners();
    } catch(e) {
      print('removeExercise error $e');
    }
  }
}