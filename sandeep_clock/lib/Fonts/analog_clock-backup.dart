// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:analog_clock/main.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'package:analog_clock/clockTextHelper.dart';
import 'package:analog_clock/container_hand.dart';
import 'package:analog_clock/drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);
var _now = DateTime.now();

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock>
    with SingleTickerProviderStateMixin {
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;
  Animation _vOffsetTween;
  AnimationController controller;

  @override
  void initState() {
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _vOffsetTween = TweenSequence([
      TweenSequenceItem<Offset>(
          tween: Tween(begin: Offset(0, 0), end: Offset(-1, 2))
              .chain(CurveTween(curve: Curves.decelerate)),
          weight: 80),
      TweenSequenceItem<Offset>(
          tween: Tween(begin: Offset(0.2, 1), end: Offset(0, 0))
              .chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn)),
          weight: 20)
    ]).animate(controller);

    controller.forward();

    widget.model.addListener(_updateModel);

    // Set the initial values.
    super.initState();
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    controller.reset();
    controller.forward();

    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        //Duration(minutes: 1) - Duration(seconds: _now.second),
        Duration(seconds: 5) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Color(0xFF669DF6),
            // backgroundColor: Color(0xFFD2E3FC),
            backgroundColor: Colors.black,
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());
    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature),
          Text(_temperatureRange),
          Text(_condition),
          Text(_location),
          Text('$_now'),
        ],
      ),
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        padding: EdgeInsets.only(top: 30),
        color: customTheme.backgroundColor,
        child: Stack(
          children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    '${Returnhourtext(_now.hour)}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontFamily: 'Comfortaa',
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    '${Returnminutetext_beforespace(_now.second)}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontFamily: 'Comfortaa',
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SlideTransition(
                    position: _vOffsetTween,
                    child: Text(
                      '${Returnminutetext_afterspace(_now.second)}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontFamily: 'Comfortaa',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: randomtextwidgets(),
              ),
            ),

            // Example of a hand drawn with [CustomPainter].
            DrawnHand(
              color: customTheme.accentColor,
              thickness: 4,
              size: 1,
              angleRadians: _now.second * radiansPerTick,
            ),
            DrawnHand(
              color: customTheme.highlightColor,
              thickness: 16,
              size: 0.9,
              angleRadians: _now.minute * radiansPerTick,
            ),
            // Example of a hand drawn with [Container].
            ContainerHand(
              color: Colors.transparent,
              size: 0.5,
              angleRadians: _now.hour * radiansPerHour +
                  (_now.minute / 60) * radiansPerHour,
              child: Transform.translate(
                offset: Offset(0.0, -60.0),
                child: Container(
                  width: 32,
                  height: 150,
                  decoration: BoxDecoration(
                    color: customTheme.primaryColor,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                //child: weatherInfo,
                child: Text(
                  '' + _now.minute.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

randomtextwidgets() {
  var minute = _now.minute;
  var hour = _now.hour;

  TextStyle minutestle_now =
      TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w400);
  TextStyle minutestle_notnow =
      TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w200);

  TextStyle hourestyle_now =
      TextStyle(color: Colors.red, fontSize: 35, fontWeight: FontWeight.w400);
  TextStyle hourstyle_notnow =
      TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.w200);

  var _hours = List<int>.generate(25, (i) => i + 1);

  var _minutes = List<int>.generate(61, (i) => i + 1);
  Map<String, int> _minutemap =
      Map.fromIterable(_minutes, key: (e) => 'm$e', value: (e) => e);

  var _hourmap = Map.fromIterable(_hours, key: (e) => 'h$e', value: (e) => e);
  var _finalmap = {}..addAll(_minutemap)..addAll(_hourmap);

  List<Widget> widgettextlist = [];

  void iterateMapEntry(k, v) {
    print(k.toString());
    if (k.contains('h')) {
      print('entered loop');
      if (v == _now.hour) {
        widgettextlist.add(Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
          child: Text(
            '$v',
            style: hourestyle_now,
          ),
        ));
      } else {
        widgettextlist.add(Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
          child: Text(
            '$v',
            style: hourstyle_notnow,
          ),
        ));
      }
    } else {
      if (v == _now.minute) {
        widgettextlist.add(Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
          child: Text(
            '$v',
            style: minutestle_now,
          ),
        ));
      } else {
        widgettextlist.add(Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
          child: Text(
            '$v',
            style: minutestle_notnow,
          ),
        ));
      }
    }
  }

  _finalmap.forEach((k, v) => iterateMapEntry(k, v));

  print(widgettextlist.length);

  widgettextlist.shuffle();

  return widgettextlist;
}
