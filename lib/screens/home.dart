import 'package:flutter/material.dart';
import 'package:flutter_app/providers/schedule_provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/screens/trainee/schedule_list.dart';
import 'package:flutter_app/screens/trainee/trainee_screen.dart';
import 'package:flutter_app/screens/coach/coach_screen.dart';
import 'package:provider/src/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().id;
    final userRole = context.read<UserProvider>().role;

    return Scaffold(
      appBar: AppBar(title: Text(DateFormat.yMMMEd().format(DateTime.now()))),
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              color: Colors.orangeAccent,
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.food_bank_outlined, size: 70, color: Colors.white),
                    Text('Nutrition', style: TextStyle(fontSize: 40, color: Colors.white))
                  ],)
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => userRole == 'TRAINEE' ? TraineeScreen() : CoachScreen(),
                  ),
                );
              },
              child: Container(
                color: Colors.lightBlueAccent,
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports, size: 70, color: Colors.white),
                        Text('Sports', style: TextStyle(fontSize: 40, color: Colors.white))
                      ],)
                ),
              ),
            ),
          ),
        ],
      )
      // bottomNavigationBar: BottomNavigationBar(items: const [
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.schedule, size: 10, color: Colors.black)
      //   )
      // ],),
    );
  }
}
