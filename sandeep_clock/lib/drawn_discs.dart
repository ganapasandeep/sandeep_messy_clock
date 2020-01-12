import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart' show radians;

class DrawDisc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _CirclePainter(),
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPainter = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = size.width / 12
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset((Offset.zero & size).center.dx, (Offset.zero & size).center.dy),
      size.width / 10,
      backgroundPainter..color = Colors.pinkAccent,
    );

    canvas.drawCircle(
      Offset((Offset.zero & size).center.dx, (Offset.zero & size).center.dy),
      size.width / 5.5,
      backgroundPainter..color = Colors.black,
    );

    canvas.drawCircle(
      Offset((Offset.zero & size).center.dx, (Offset.zero & size).center.dy),
      size.width / 3.8,
      backgroundPainter..color = Colors.black,
    );

    for (var i = 0; i < 30; i++) {
      var radiansPerTick = radians(360 / 60);
      var angleRadians = radiansPerTick * i * 2;
      var angle = angleRadians - math.pi / 2;
      Offset position = (Offset.zero & size).center +
          Offset(math.cos(angle), math.sin(angle)) * 60;
      TextSpan span = new TextSpan(
          style: new TextStyle(color: Colors.white, fontSize: 6),
          text: '${i * 2}');
      TextPainter tp =
          new TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, position);
    }

    for (var i = 0; i < 60; i++) {
      var radiansPerTick = radians(360 / 60);
      var angleRadians = radiansPerTick * i;
      var angle = angleRadians - math.pi / 2;
      Offset position = (Offset.zero & size).center +
          Offset(math.cos(angle), math.sin(angle)) * 120;
      TextSpan span = new TextSpan(
          style: new TextStyle(color: Colors.white, fontSize: 7), text: '$i');
      TextPainter tp =
          new TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, position);
    }

    for (var i = 0; i < 12; i++) {
      var radiansPerTick = radians(360 / 12);
      var angleRadians = radiansPerTick * i;
      var angle = angleRadians - math.pi / 2;
      Offset position = (Offset.zero & size).center +
          Offset(math.cos(angle), math.sin(angle)) * 180;
      TextSpan span = new TextSpan(
          style: new TextStyle(color: Colors.white, fontSize: 17), text: '$i');
      TextPainter tp =
          new TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, position);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
