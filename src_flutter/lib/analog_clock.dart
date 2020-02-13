// Author   => Sebastian Camilo Rozo Rozo
// email    => camynator@yahoo.es
// Github   => https://github.com/SebastianRozoCode
// Address  => Colombia, Cundinamarca, Chia.
// Date     => 15/01/2020

// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'CustomBackground.dart';
import 'container_hand.dart';
//import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
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
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF8AB4F8),
            accentColor: Colors.black,
            backgroundColor: Color(0xFFD2E3FC),
            primaryColorLight: Color.fromRGBO(41, 153, 225, 8),
            secondaryHeaderColor: Color.fromRGBO(37, 136, 170, 9))
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
            primaryColorLight: Color.fromRGBO(12, 19, 30, 8),
            secondaryHeaderColor: Color.fromRGBO(20, 30, 33, 2));

    final time = DateFormat.Hms().format(DateTime.now());
    /* Label Temperature , condition */
    final weatherInfoPanel1 = DefaultTextStyle(
      style: TextStyle(color: customTheme.accentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _temperature + '\n' + _condition,
            style: TextStyle(
                fontStyle: FontStyle.italic,
                color: customTheme.accentColor,
                fontWeight: FontWeight.w500,
                fontSize: 10),
          )
        ],
      ),
    );

    /* Label Location , Temperature Range*/
    final weatherInfoPanel2 = DefaultTextStyle(
      style: TextStyle(
        color: customTheme.accentColor,
      ),
      textAlign: TextAlign.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _location + '\n' + _temperatureRange,
            style: TextStyle(
                fontStyle: FontStyle.italic,
                color: customTheme.accentColor,
                fontWeight: FontWeight.w500,
                fontSize: 10),
          ),
        ],
      ),
    );

    /* Background black */
    final backBlackClock = new Container(
      width: double.infinity,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        gradient: new LinearGradient(
            colors: [
              customTheme.primaryColorLight,
              customTheme.secondaryHeaderColor,
              customTheme.primaryColorLight
            ],
            begin: const FractionalOffset(1.0, 0.1),
            end: const FractionalOffset(1.0, 0.9)),
        boxShadow: [
          new BoxShadow(
            offset: new Offset(0.0, 0.0),
            blurRadius: 1.0,
          )
        ],
      ),
    );

    /* Label time */
    final labelTime = new Text(
      _now.hour.toString() +
          '  ' +
          (_now.minute < 10
              ? '0' + _now.minute.toString()
              : _now.minute.toString()),
      style: TextStyle(
          fontStyle: FontStyle.italic,
          color: customTheme.accentColor,
          fontWeight: FontWeight.w900,
          fontSize: 40),
    );

    final backDrawNumbers = new Container(
        width: double.infinity,
        padding: const EdgeInsets.all(0.1),
        child: Transform.translate(
            offset: Offset(76.0, 3),
            child: Container(
              child: new CustomPaint(
                painter: new CustomBackground(clockText: ClockText.roman),
              ),
            )));

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: Stack(
          children: <Widget>[
            backBlackClock,
            new Container(alignment: Alignment.center, child: labelTime),
            new Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                left: 40,
                top: 55,
                right: 40,
              ),
              child: weatherInfoPanel1,
            ),
            new Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                left: 40,
                top: 135,
                right: 40,
              ),
              child: weatherInfoPanel2,
            ),
            backDrawNumbers,
            ContainerHand(
              color: Colors.transparent,
              size: 0.7,
              angleRadians: _now.second * radiansPerTick +
                  (_now.second / 60) * radiansPerTick,
              child: Transform.translate(
                offset: Offset(0.0, -60.0),
                child: Container(
                  width: 1.5,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            new Center(
              child: new Container(
                width: 5.0,
                height: 5.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
