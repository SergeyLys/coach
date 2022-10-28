import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/providers/exercises_provider.dart';
import 'package:provider/src/provider.dart';

class ExercisesDropdown extends StatefulWidget {
  final Function onChangeCallback;

  const ExercisesDropdown({Key? key, required this.onChangeCallback})
      : super(key: key);

  @override
  State<ExercisesDropdown> createState() => _ExercisesDropdownState();
}

class _ExercisesDropdownState extends State<ExercisesDropdown> {
  // Exercise dropdownValue;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: context.read<ExercisesProvider>().fetchExercises(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          return isLoading ? const Center(child: CircularProgressIndicator()) : DropdownButton<Exercise>(
            value: context.watch<ExercisesProvider>().list.first,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.black),
            underline: Container(
              height: 2,
              color: Colors.blueAccent,
            ),
            onChanged: (Exercise? value) {
              // This is called when the user selects an item.
              // setState(() {
              //   dropdownValue = value!;
              // });

              if (value != null) {
                widget.onChangeCallback(value.id);
              }
            },
            items: context.watch<ExercisesProvider>().list.map((Exercise exercise) {
              return DropdownMenuItem<Exercise>(
                value: exercise,
                child: Text(exercise.name),
              );
            }).toList(),
          );
        });
  }
}