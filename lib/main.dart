import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/providers/gym_event_provider.dart';
import 'package:flutter_app/screens/login.dart';
import 'package:flutter_app/screens/home.dart';
import 'package:flutter_app/screens/register.dart';
import 'package:flutter_app/screens/user_event_constructor.dart';

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
        ChangeNotifierProvider<GymEventProvider>(
          create: (context) => GymEventProvider(),
        ),
      ],

      child: MaterialApp(
        title: 'Test',
        home: UserEventConstructor(),
        routes: {
          "/login": (context) => Login(),
          "/register": (context) => Register(),
          "/home": (context) => Home(),
          "/event-constructor": (context) => UserEventConstructor(),
        },
      ),
    );
  }
}

