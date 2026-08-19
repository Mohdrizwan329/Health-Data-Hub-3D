import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints the semicircular banded dial used on the organ score detail.
///
/// The arc is split into equal coloured segments, each labelled outside the
/// rim, with a pivoting needle indicating where the score falls.
class NeedleGaugePainter extends CustomPainter {
  NeedleGaugePainter({
    required this.progress,
    required this.fraction,
    required this.segmentColors,
    required this.segmentLabels,
    required this.labelStyle,
  }) : assert(
         segmentColors.length == segmentLabels.length,
         'each segment needs a label',
       );

  /// Sweep-in animation position, 0..1.
  final double progress;

  /// Where the needle settles, as 0..1 across the whole arc.
  final double fraction;
  final List<Color> segmentColors;
  final List<String> segmentLabels;
  final TextStyle labelStyle;

  static const _start = math.pi; // 9 o'clock
  static const _sweep = math.pi; // half turn to 3 o'clock

  final Map<String, TextPainter> _labels = {};

  @override
  void paint(Canvas canvas, Size size) {
    // The pivot sits on the baseline, so the dial occupies the upper half.
    final pivot = Offset(size.width / 2, size.height);
    final band = math.min(size.width / 2, size.height) * 0.135;
    // Leave room outside the rim for the segment captions, which are widest at
    // the extremes ("Very Low" / "Very High").
    final radius = math.min(size.width / 2, size.height) * 0.63;

    _paintSegments(canvas, pivot, radius, band);
    _paintLabels(canvas, pivot, radius + band * 0.5 + 13);
    _paintNeedle(canvas, pivot, radius);
  }

  void _paintSegments(Canvas canvas, Offset pivot, double radius, double band) {
    final rect = Rect.fromCircle(center: pivot, radius: radius);
    final each = _sweep / segmentColors.length;
    // A small gap keeps the segments visually separate, as in the design.
    const gap = 0.012;

    for (var i = 0; i < segmentColors.length; i++) {
      final from = _start + each * i + gap;
      final extent = (each - gap * 2) * progress;
      if (extent <= 0) continue;
      canvas.drawArc(
        rect,
        from,
        extent,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = band
          ..color = segmentColors[i],
      );
    }
  }

  void _paintLabels(Canvas canvas, Offset pivot, double radius) {
    final each = _sweep / segmentLabels.length;
    for (var i = 0; i < segmentLabels.length; i++) {
      final mid = _start + each * (i + 0.5);
      final tp = _labels.putIfAbsent(
        segmentLabels[i],
        () => TextPainter(
          text: TextSpan(text: segmentLabels[i], style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout(),
      );
      final at = Offset(
        pivot.dx + radius * math.cos(mid),
        pivot.dy + radius * math.sin(mid),
      );
      tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _paintNeedle(Canvas canvas, Offset pivot, double radius) {
    final angle = _start + _sweep * (fraction * progress).clamp(0.0, 1.0);
    final tip = Offset(
      pivot.dx + radius * 0.92 * math.cos(angle),
      pivot.dy + radius * 0.92 * math.sin(angle),
    );

    // Tapered needle: wide at the hub, pointed at the tip.
    final perp = angle + math.pi / 2;
    const halfWidth = 5.0;
    final a = Offset(
      pivot.dx + halfWidth * math.cos(perp),
      pivot.dy + halfWidth * math.sin(perp),
    );
    final b = Offset(
      pivot.dx - halfWidth * math.cos(perp),
      pivot.dy - halfWidth * math.sin(perp),
    );
    canvas.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(b.dx, b.dy)
        ..close(),
      Paint()..color = const Color(0xFFBFBFBF),
    );

    canvas.drawCircle(pivot, 13, Paint()..color = Colors.white);
    canvas.drawCircle(
      pivot,
      13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x33000000),
    );
  }

  @override
  bool shouldRepaint(covariant NeedleGaugePainter old) =>
      old.progress != progress ||
      old.fraction != fraction ||
      !identical(old.segmentColors, segmentColors);
}
