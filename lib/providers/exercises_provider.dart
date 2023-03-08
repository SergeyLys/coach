import 'package:flutter/cupertino.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/domains/muscle_group.dart';
import 'package:flutter_app/services/network_service.dart';

class ExercisesProvider extends ChangeNotifier {
  List<Exercise> list = [];
  List<MuscleGroup> groups = [];
  bool isLoading = false;
  bool isGroupsLoading = false;
  bool isExerciseCreating = false;

  Future<void> fetchExercises() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await NetworkService().get(
          '$apiUrl/exercises'
      );

      final result = response.map<Exercise>((json) => Exercise.fromJson(json)).toList();

      list = result;

      isLoading = false;
      notifyListeners();
    } catch(e) {
      isLoading = false;
      notifyListeners();
      print('fetchExercises error $e');
    }
  }

  Future<void> fetchMuscleGroups() async {
    try {
      isGroupsLoading = true;
      notifyListeners();

      final response = await NetworkService().get(
          '$apiUrl/muscle-group'
      );

      final result = response.map<MuscleGroup>((json) => MuscleGroup.fromJson(json)).toList();

      groups = result;

      isGroupsLoading = false;
      notifyListeners();
    } catch(e) {
      isGroupsLoading = false;
      notifyListeners();
      print('fetchMuscleGroups error $e');
    }
  }

  Future<void> createExercise(int muscleGroupId, String name, String description) async {
    try {
      isExerciseCreating = true;
      notifyListeners();

      final response = await NetworkService().post(
          '$apiUrl/exercises/create',
          body: {
            'muscleGroupId': muscleGroupId,
            'name': name,
            'description': description
          }
      );

      final result = Exercise.fromJson(response);

      list.add(result);

      isExerciseCreating = false;
      notifyListeners();
    } catch(e) {
      isExerciseCreating = false;
      notifyListeners();
      print('createExercise error $e');
    }
  }
}