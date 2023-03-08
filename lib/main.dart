import 'package:flutter/material.dart';
import 'package:flutter_app/providers/trainee-event_provider.dart';
import 'package:flutter_app/providers/coach-event_provider.dart';
import 'package:flutter_app/providers/exercises_provider.dart';
import 'package:flutter_app/providers/schedule_provider.dart';
import 'package:flutter_app/screens/coach/coach_screen.dart';
import 'package:flutter_app/screens/exercise-wizard/wizard-screen.dart';
import 'package:flutter_app/screens/trainee/trainee_screen.dart';
import 'package:flutter_app/theme/theme_constants.dart';
import 'package:flutter_app/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/screens/login.dart';
import 'package:flutter_app/screens/register.dart';

ThemeManager _themeManager = ThemeManager();

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
        themeMode: _themeManager.themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
        title: 'Test',
        home: Login(),
        routes: {
          "/login": (context) => Login(),
          "/register": (context) => Register(),
          "/coach-screen": (context) => CoachScreen(),
          "/trainee-screen": (context) => TraineeScreen(),
          "/exercise-wizard": (context) => ExerciseWizard(),
        },
      ),
    );
  }
}

