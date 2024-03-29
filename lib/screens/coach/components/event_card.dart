import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_app/assets/utils.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/domains/gym_event_coach.dart';

const dragPointSize = 15.0;
const discreteStepSize = 15;

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall({Key? key, required this.onDrag}) : super(key: key);

  final Function onDrag;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  late double initY;

  _handleDrag(details) {
    setState(() {
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dy = details.globalPosition.dy - initY;
    initY = details.globalPosition.dy;
    widget.onDrag(dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _handleDrag,
      onVerticalDragUpdate: _handleUpdate,
      child: Container(
        width: dragPointSize,
        height: dragPointSize,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
        ),
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final double scrollPosition;
  final CoachEvent event;
  final List<double> hours;
  final double initialTopOffset;
  final Function(CoachEvent event) onTap;
  final Function(CoachEvent event) onLongPress;
  final Function(CoachEvent event, double top, double height) handleChangeEventRange;
  final double width;
  final double left;
  final List<CoachEvent> events;
  final DateTime currentDate;
  // final Color bg;

  const EventCard(
      {Key? key,
      required this.hours,
      required this.scrollPosition,
      required this.event,
      required this.initialTopOffset,
      required this.onTap,
      required this.onLongPress,
      required this.handleChangeEventRange,
      required this.width,
      required this.left,
      required this.events,
      required this.currentDate,
      // required this.bg,
      })
      : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late double _top = 0;
  late double _touchPos;
  late double _bottomLimit;
  late double _duration;
  late double _height;
  final double _minHeight = 15;

  double cumulativeDy = 0;

  @override
  void initState() {
    super.initState();
    DateTime startDate = DateTime.parse(widget.event.startDate).toLocal();
    DateTime endDate = DateTime.parse(widget.event.endDate).toLocal();
    DateTime time = startDate;
    time = DateTime(time.year, time.month, time.day, 0);
    double startMinutes = getDifferenceInMinutes(time, startDate).toDouble();
    _top = getClosestNumber(startMinutes, widget.hours);
    _duration = getDifferenceInMinutes(startDate, endDate).toDouble();
    _bottomLimit = getClosestNumber(minutesInDay - _duration, widget.hours);
    _height = _duration;
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.width;
    final cardLeft = widget.left;
    return Stack(children: [
      Positioned(
        top: _top,
        height: _height,
        left: cardLeft,
        child: GestureDetector(
          child: Container(
            height: _height,
            width: cardWidth,
            // color: widget.bg,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text('${widget.event.assignee.email} ${widget.event.id}'),
            ),
          ),
          onLongPress: () {
            widget.onLongPress(widget.event);
          },
          onTap: () {
            widget.onTap(widget.event);
          },
          onVerticalDragDown: (DragDownDetails details) {
            setState(() {
              _touchPos = details.localPosition.dy;
            });
          },
          onLongPressMoveUpdate: (details) {
            double topPos = ((details.globalPosition.dy + widget.scrollPosition) - _touchPos) - widget.initialTopOffset;

            if (topPos > _bottomLimit) {
              return;
            }

            setState(() {
              _top = getClosestNumber(topPos, widget.hours);
            });
          },
        ),
      ),
      Positioned(
        top: _top - dragPointSize / 2,
        left: cardLeft - 15 + cardWidth / 2 + dragPointSize / 2,
        width: dragPointSize,
        height: dragPointSize,
        child: ManipulatingBall(
          onDrag: (dy) {
            cumulativeDy -= dy;

            if(cumulativeDy >= discreteStepSize) {
              setState(() {
                var newHeight = _height + discreteStepSize;
                _top = _top - discreteStepSize;
                _height = newHeight > 0 ? newHeight : 0;
                cumulativeDy = 0;
              });
              widget.handleChangeEventRange(widget.event, _top, _height);
            } else if (cumulativeDy <= -discreteStepSize) {
              setState(() {
                var newHeight = _height - discreteStepSize;
                _top = _top + discreteStepSize;
                _height = newHeight > 0 ? newHeight : 0;
                cumulativeDy = 0;
              });
              widget.handleChangeEventRange(widget.event, _top, _height);
            }
          },
        ),
      ),
      Positioned(
        top: _top + _height - dragPointSize / 2,
        left: cardLeft - 15 + cardWidth / 2 + dragPointSize / 2,
        child: ManipulatingBall(
          onDrag: (dy) {
            cumulativeDy += dy;

            if (cumulativeDy >= discreteStepSize) {
              setState(() {
                var newHeight = _height + discreteStepSize;
                _height = newHeight > _minHeight ? newHeight : _minHeight;
                cumulativeDy = 0;
              });
              widget.handleChangeEventRange(widget.event, _top, _height);
            } else if (cumulativeDy <= -discreteStepSize) {
              setState(() {
                var newHeight = _height - discreteStepSize;
                _height = newHeight > _minHeight ? newHeight : _minHeight;
                cumulativeDy = 0;
              });
              widget.handleChangeEventRange(widget.event, _top, _height);
            }
          },
        ),
      ),
    ]);
  }
}
