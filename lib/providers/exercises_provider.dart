import 'package:flutter/cupertino.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/services/network_service.dart';

class ExercisesProvider extends ChangeNotifier {
  List<Exercise> list = [];

  Future<void> fetchExercises() async {
    try {
      final response = await NetworkService().get(
          '$apiUrl/exercises'
      );

      final result = response.map<Exercise>((json) => Exercise.fromJson(json)).toList();

      list = result;

      notifyListeners();
    } catch(e) {
      print('fetchExercises error $e');
    }
  }
}