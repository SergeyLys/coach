import 'package:flutter/material.dart';
import 'package:flutter_app/providers/schedule_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/screens/login.dart';
import 'package:flutter_app/screens/home.dart';
import 'package:flutter_app/screens/register.dart';
import 'package:flutter_app/screens/schedule_constructor/schedule_constructor.dart';

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
      ],

      child: MaterialApp(
        title: 'Test',
        home: Home(),
        routes: {
          "/login": (context) => Login(),
          "/register": (context) => Register(),
          "/home": (context) => Home(),
          "/event-constructor": (context) => ScheduleConstructor(),
        },
      ),
    );
  }
}

