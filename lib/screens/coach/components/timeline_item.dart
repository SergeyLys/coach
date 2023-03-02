import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimelineItem extends StatefulWidget {
  final double position;
  final Function(double position) onLongTap;
  const TimelineItem({Key? key, required this.position, required this.onLongTap}) : super(key: key);

  @override
  State<TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<TimelineItem> {
  @override
  Widget build(BuildContext context) {
    double time = widget.position / 60;
    double fract = time - time.truncate();
    int minutes = ((fract * 60 / 100) * 100).truncate();
    int hours = time.truncate();
    bool isMinutes = fract > 0;

    return Positioned(
      top: widget.position,
      child: isMinutes
          ? Container(
          padding: EdgeInsets.only(left: 25),
          child: Stack(
            children: [
              GestureDetector(
                onLongPressStart: (det) {
                  widget.onLongTap(det.globalPosition.dy);
                },
                child: Container(
                  padding: EdgeInsets.only(left: 45),
                  child: SizedBox(
                    height: 15,
                    width: MediaQuery.of(context)
                        .size
                        .width,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0)
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: -7,
                width:
                MediaQuery.of(context).size.width,
                child: Divider(
                    color: Colors.black
                        .withOpacity(0.3)),
              ),
              Text(
                '$minutes',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black
                        .withOpacity(0.3)),
              ),
            ],
          ))
          : Stack(
        children: [
          GestureDetector(
            onLongPressStart: (det) {
              widget.onLongTap(det.globalPosition.dy);
            },
            child: Container(
              padding: EdgeInsets.only(left: 45),
              child: SizedBox(
                height: 15,
                width:
                MediaQuery.of(context).size.width,
              ),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0)
              ),
            ),
          ),
          Positioned(
            left: 45,
            top: -7,
            width:
            MediaQuery.of(context).size.width,
            child: Divider(color: Colors.black),
          ),
          Text(
            (hours < 10
                ? '0' + hours.toString()
                : hours.toString()) +
                ':00',
          ),
        ],
      )
    );
  }
}

