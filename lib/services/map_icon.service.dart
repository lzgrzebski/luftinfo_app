import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:tinycolor/tinycolor.dart';

class MapIconService {
  static Future<Uint8List> createIcon(int value, String color,
      [bool isActive = false]) async {
    final double width = 120;
    final double height = 120;
    final colorBackground =
        Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(width, height)));
    final paint = Paint()
      ..color = colorBackground
      ..style = PaintingStyle.fill;
    final paintStroke = Paint()
      ..color =
          isActive ? Colors.white : TinyColor(colorBackground).darken(5).color
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 5 : 2;
    final painter = TextPainter(
        textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    final center = new Offset(width / 2, height / 2);
    final radius = min(width / 2, height / 2);

    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius - 2, paintStroke);
    painter.text = TextSpan(
      text: value.toString(),
      style: TextStyle(
          fontSize: 45.0, color: Colors.white, fontWeight: FontWeight.bold),
    );

    painter.layout(minWidth: width, maxWidth: width);
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * .5) - painter.height * 0.5));

    final img =
        await recorder.endRecording().toImage(width.round(), height.round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }
}
