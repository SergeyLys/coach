import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/domains/gym_event_trainee.dart';
import 'package:flutter_app/providers/trainee-event_provider.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create an exercise"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
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
          ],
        ),
      )
    );
  }
}