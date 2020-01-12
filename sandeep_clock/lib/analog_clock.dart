// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

var _now = DateTime.now();

class MessyClock extends StatefulWidget {
  const MessyClock(this.model);
  final ClockModel model;

  @override
  _MessyClockState createState() => _MessyClockState();
}

class _MessyClockState extends State<MessyClock> {
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    widget.model.addListener(_updateModel);
    super.initState();
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(MessyClock oldWidget) {
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
    setState(() {
      _now = DateTime.now();
      _timer = Timer(
        //Duration(minutes: 1) - Duration(seconds: _now.second),
        Duration(seconds: 5) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Current Hour Number.
            primaryColor: Colors.red,
            // Current Minute Number.
            highlightColor: Colors.green,
            // Non-Current Hour Number.
            accentColor: Colors.grey[300],
            //Non-Current Minute Number
            hoverColor: Colors.grey[400],

            backgroundColor: Color.fromRGBO(232, 232, 232, 0.8),
            //backgroundColor: Colors.black,
          )
        : Theme.of(context).copyWith(
            // Current Hour Number.
            primaryColor: Colors.red,
            // Current Minute Number.
            highlightColor: Colors.green,
            // Non-Current Hour Number.
            accentColor: Colors.grey[100].withOpacity(0.1),
            //Non-Current Minute Number
            hoverColor: Colors.grey[100].withOpacity(0.2),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Messy clock with time $time',
        value: time,
      ),
      child: Container(
        padding: EdgeInsets.only(top: 15),
        color: customTheme.backgroundColor,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.only(bottom: 2),
                child: Wrap(
                  runAlignment: WrapAlignment.spaceEvenly,
                  spacing: 5.0,
                  runSpacing: 2.0,
                  children: randomtextwidgets(customTheme),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 8),
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('$_condition',
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Comfortaa',
                          fontSize: 15)),
                  Text(
                    '${DateFormat('EEEE MMM d').format(_now)}',
                    style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Comfortaa',
                        fontSize: 15),
                  ),
                  Text('$_temperature',
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Comfortaa',
                          fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

randomtextwidgets([ThemeData customTheme]) {
  TextStyle minutestle_now = TextStyle(
      color: customTheme.highlightColor,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'Comfortaa');
  TextStyle minutestle_notnow = TextStyle(
      color: customTheme.hoverColor,
      fontSize: 15,
      fontWeight: FontWeight.w200,
      fontFamily: 'Comfortaa');

  TextStyle hourestyle_now = TextStyle(
      color: customTheme.primaryColor,
      fontSize: 35,
      fontWeight: FontWeight.w400,
      fontFamily: 'Comfortaa');
  TextStyle hourstyle_notnow = TextStyle(
      color: customTheme.accentColor,
      fontSize: 35,
      fontWeight: FontWeight.w500,
      fontFamily: 'Comfortaa');

  var _hours = List<int>.generate(25, (i) => i + 1);
  var _minutes = List<int>.generate(61, (i) => i + 1);
  Map<String, String> _minutemap = Map.fromIterable(
    _minutes,
    key: (e) => 'm$e',
    value: (e) => e.toString(),
  );
  var _hourmap = Map.fromIterable(
    _hours,
    key: (e) => 'h$e',
    value: (e) => e.toString(),
  );
  _minutemap['m00'] = "00";
  _hourmap['h00'] = "00";
  var _finalmap = {}..addAll(_minutemap)..addAll(_hourmap);

  List<Widget> widgettextlist = [];
  void iterateMapEntry(k, v) {
    if (k.contains('h')) {
      if (num.parse(v) == _now.hour) {
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
      if (num.parse(v) == _now.minute) {
        widgettextlist.add(Container(
          width: 40,
          height: 40,
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
          width: 29,
          height: 29,
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

  widgettextlist.shuffle();

  return widgettextlist;
}
