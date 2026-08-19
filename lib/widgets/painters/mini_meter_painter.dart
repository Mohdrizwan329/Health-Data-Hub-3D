import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The small half-dial under the score summary reading.
class MiniMeterPainter extends CustomPainter {
  const MiniMeterPainter({required this.fraction, required this.color});

  /// Fill across the half turn, 0..1.
  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) * 0.92;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.14),
    );
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * fraction.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant MiniMeterPainter old) =>
      old.fraction != fraction || old.color != color;
}
