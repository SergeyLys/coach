import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/domains/gym_event_trainee.dart';
import 'package:flutter_app/domains/muscle_group.dart';
import 'package:flutter_app/providers/exercises_provider.dart';
import 'package:flutter_app/providers/trainee-event_provider.dart';
import 'package:flutter_app/screens/exercise-wizard/muscle_group_dropdown.dart';
import 'package:intl/intl.dart';

import 'package:flutter_app/assets/constants.dart';
import 'package:provider/provider.dart';
// import './exercises_dropdown.dart';
import '../../../components/week_day_dot.dart';

class ExerciseWizard extends StatefulWidget {
  const ExerciseWizard({Key? key,
  }) : super(key: key);

  @override
  State<ExerciseWizard> createState() => _ExerciseWizardState();
}

class _ExerciseWizardState extends State<ExerciseWizard> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  late MuscleGroup? selectedMuscleGroup = null;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExercisesProvider>(
      builder: (context, provider, child) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Create an exercise"),
              centerTitle: true,
            ),
            body: Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15,),
                  const Text('Select muscle group', style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 5,),
                  MuscleGroupDropdown(
                    selectedItem: selectedMuscleGroup,
                    onChangeCallback: (MuscleGroup? item) {
                      setState(() {
                        selectedMuscleGroup = item;
                      });
                    },
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Name"),
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name of exercise';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Description"),
                    controller: descriptionController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15,),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50),
                        ),
                        onPressed: () async {
                          if (selectedMuscleGroup == null || nameController.text.isEmpty || descriptionController.text.isEmpty) {
                            return;
                          }
                          provider.createExercise(selectedMuscleGroup!.id, nameController.text, descriptionController.text).then((value) =>
                            Navigator.of(context).pop()
                          );
                        },
                        child: provider.isExerciseCreating ? Container(height: 50, child: const Center(child: CircularProgressIndicator(
                          color: Colors.white,
                        )),) : Text('Create'),
                      )
                    ),
                  ),
                  const SizedBox(height: 30,),
                ],
              ),
            )
        );
      }
    );
  }
}