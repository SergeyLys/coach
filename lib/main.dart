import 'package:flutter/material.dart';
import 'package:flutter_app/providers/trainee-event_provider.dart';
import 'package:flutter_app/providers/coach-event_provider.dart';
import 'package:flutter_app/providers/exercises_provider.dart';
import 'package:flutter_app/providers/schedule_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/screens/login.dart';
import 'package:flutter_app/screens/home.dart';
import 'package:flutter_app/screens/register.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider<ScheduleProvider>(
          create: (context) => ScheduleProvider(),
        ),
        ChangeNotifierProvider<TraineeEventProvider>(
          create: (context) => TraineeEventProvider(),
        ),
        ChangeNotifierProvider<CoachEventProvider>(
          create: (context) => CoachEventProvider(),
        ),
        ChangeNotifierProvider<ExercisesProvider>(
          create: (context) => ExercisesProvider(),
        ),
      ],

      child: MaterialApp(
        title: 'Test',
        // home: Login(),
        home: Login(),
        routes: {
          "/login": (context) => Login(),
          "/register": (context) => Register(),
          "/home": (context) => Home(),
        },
      ),
    );
  }
}

