import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Shared geometry for the circular gauges.
///
/// Both the genotype gauge and the blood-quality gauge sweep 270° starting from
/// the lower-left, so the dial maths lives here rather than in each painter.
abstract final class GaugeGeometry {
  /// Lower-left origin of the dial (Flutter angles: 0 = 3 o'clock, +ve = CW).
  static const startAngle = math.pi * 0.75;

  /// Three quarters of a turn, ending at the lower-right.
  static const sweepAngle = math.pi * 1.5;

  /// Angle at which [value] sits on a dial running 0..[max].
  static double angleFor(double value, double max) =>
      startAngle + sweepAngle * (value / max).clamp(0.0, 1.0);

  /// Point on the circle of [radius] around [centre] at [angle].
  static Offset pointOn(Offset centre, double radius, double angle) => Offset(
    centre.dx + radius * math.cos(angle),
    centre.dy + radius * math.sin(angle),
  );

  /// Evenly spaced tick angles, [count] inclusive of both ends.
  static Iterable<double> tickAngles(int count) sync* {
    if (count <= 1) {
      yield startAngle;
      return;
    }
    for (var i = 0; i < count; i++) {
      yield startAngle + sweepAngle * (i / (count - 1));
    }
  }
}
