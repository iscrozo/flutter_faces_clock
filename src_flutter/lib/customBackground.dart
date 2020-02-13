// Author   => Sebastian Camilo Rozo Rozo
// email    => camynator@yahoo.es
// Github   => https://github.com/SebastianRozoCode
// Address  => Colombia, Cundinamarca, Chia.
// Date     => 15/01/2020

import 'dart:math';
import 'package:flutter/material.dart';

class CustomBackground extends CustomPainter {
  final clockText;

  final hourTickMarkLength = 10.0;
  final minuteTickMarkLength = 5.0;

  final hourTickMarkWidth = 3.0;
  final minuteTickMarkWidth = 1.5;

  final Paint tickPaint;
  final TextPainter textPainter;
  final TextStyle textStyle;

  final romanNumeralList = [
    'XII',
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
    'X',
    'XI'
  ];

  CustomBackground({this.clockText = ClockText.roman})
      : tickPaint = new Paint(),
        textPainter = new TextPainter(
          textAlign: TextAlign.left,
          textDirection: TextDirection.rtl,
        ),
        textStyle = const TextStyle(
          color: Color(0xFFD2E3FC), //Colors.blueGrey,// Colors.black,
          fontFamily: 'Times New Roman',
          fontSize: 10.0,
        ) {
    tickPaint.color = Color(0xFFD2E3FC);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var tickMarkLength;
    final angle = 2 * pi / 60;
    final radius = size.width / 3.5;
    canvas.save();

    canvas.translate(radius, radius);
    for (var i = 0; i < 60; i++) {
      tickMarkLength = i % 5 == 0 ? hourTickMarkLength : minuteTickMarkLength;
      tickPaint.strokeWidth =
          i % 5 == 0 ? hourTickMarkWidth : minuteTickMarkWidth;
      canvas.drawLine(new Offset(0.0, -radius),
          new Offset(0.0, -radius + tickMarkLength), tickPaint);

      if (i % 5 == 0) {
        canvas.save();
        canvas.translate(0.0, -radius + 20.0);

        textPainter.text = new TextSpan(
          text: this.clockText == ClockText.roman
              ? '${romanNumeralList[i ~/ 5]}'
              : '${i == 0 ? 12 : i ~/ 5}',
          style: textStyle,
        );

        //helps make the text painted vertically
        canvas.rotate(-angle * i);

        textPainter.layout();

        textPainter.paint(canvas,
            new Offset(-(textPainter.width / 2), -(textPainter.height / 2)));

        canvas.restore();
      }

      canvas.rotate(angle);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

enum ClockText { roman, arabic }
