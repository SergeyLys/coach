import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WeekDayDot extends StatelessWidget {
  const WeekDayDot({Key? key, required this.isActive, required this.day, required this.onTap, required this.disabled}) : super(key: key);

  final String day;
  final bool isActive;
  final bool disabled;
  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!disabled) {
          onTap(day);
        }
      },
      child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
              border: Border.all(color: disabled ? Colors.black12 : Colors.blueAccent),
              shape: BoxShape.circle
          ),
          child: Center(
            child: CircleAvatar(
                radius: 16,
                backgroundColor: isActive ? (disabled ? Colors.black12 : Colors.blueAccent) : Color(0xFFFFFF),
                child: Container(
                  padding: EdgeInsets.all(3),
                  child: Text(day, style: TextStyle(color: isActive ? Colors.white : (disabled ? Colors.black12 : Colors.blueAccent), fontSize: 12),),
                )
            ),
          )
      ),
    );
  }
}