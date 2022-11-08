import 'package:flutter/cupertino.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/services/network_service.dart';

class ExercisesProvider extends ChangeNotifier {
  List<Exercise> list = [];
  bool isLoading = false;

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
      print('fetchExercises error $e');
    }
  }
}