import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'gauge_geometry.dart';

/// The two circular dials in the design.
///
/// They share a dial, a tick ring and a bar ring, and differ in how progress is
/// expressed: the genotype dial uses a needle over long radial bars, while the
/// blood-quality dial uses a thick capped arc with a knob.
enum ScoreGaugeVariant { genotype, quality }

/// Paints a circular score dial.
///
/// Everything is derived from the shortest side, so a single painter serves the
/// gauge at any size without magic numbers leaking into the widget layer.
class ScoreGaugePainter extends CustomPainter {
  ScoreGaugePainter({
    required this.progress,
    required this.value,
    required this.maxValue,
    required this.variant,
    required this.accent,
    required this.tickLabels,
    required this.labelStyle,
    this.trackColor = const Color(0xFF0C0D15),
    this.ringColor = const Color(0xFF1C1E2B),
    this.tickColor = const Color(0xFF3A3D4D),
    this.innerGlow,
    this.ringAccent,
  }) : assert(maxValue > 0, 'maxValue must be positive');

  /// Animation position in 0..1; the dial fills to `progress * value`.
  final double progress;

  /// Value the dial settles on, in the same units as [maxValue].
  final double value;
  final double maxValue;
  final ScoreGaugeVariant variant;
  final Color accent;

  /// Labels drawn around the dial, spaced evenly across the sweep.
  final List<String> tickLabels;
  final TextStyle labelStyle;
  final Color trackColor;
  final Color ringColor;
  final Color tickColor;

  /// Optional halo ringing the centre well, as on the condition dial.
  final Color? innerGlow;

  /// Rim colour when it differs from the bars — the condition dial pairs a red
  /// rim with amber bars.
  final Color? ringAccent;

  Color get _rim => ringAccent ?? accent;

  /// Cached so repeated paints during the fill animation avoid re-layout.
  final Map<String, TextPainter> _labelCache = {};

  double get _shownValue => value * progress;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    // The quality dial captions its rim from outside; the genotype and
    // condition dials tuck their numbers inside the tick band.
    final labelsOutside = variant == ScoreGaugeVariant.quality;
    final labelInset = (tickLabels.isEmpty || !labelsOutside)
        ? 0.0
        : radius * 0.16;
    final dialRadius = radius - labelInset;

    // Outside labels go down first so the rim can overlap them; inside labels
    // go last so the tick band does not paint over them.
    if (labelsOutside) _paintLabels(canvas, centre, radius);

    switch (variant) {
      case ScoreGaugeVariant.genotype:
        _paintGenotype(canvas, centre, dialRadius);
      case ScoreGaugeVariant.quality:
        _paintQuality(canvas, centre, dialRadius);
    }

    if (!labelsOutside) {
      _paintLabels(canvas, centre, dialRadius * 0.735, absolute: true);
    }
  }

  // ── Genotype dial ─────────────────────────────────────────────────────────

  void _paintGenotype(Canvas canvas, Offset centre, double r) {
    final ringRect = Rect.fromCircle(center: centre, radius: r);

    // Outer glowing hairline.
    canvas.drawArc(
      ringRect,
      GaugeGeometry.startAngle,
      GaugeGeometry.sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _rim
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawArc(
      ringRect,
      GaugeGeometry.startAngle,
      GaugeGeometry.sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = _rim.withValues(alpha: 0.9),
    );

    // Dark tick band sitting just inside the hairline.
    final bandOuter = r * 0.96;
    final bandInner = r * 0.80;
    _paintBand(canvas, centre, bandOuter, bandInner, trackColor);
    _paintTicks(
      canvas,
      centre,
      outer: bandOuter - r * 0.02,
      inner: bandInner + r * 0.04,
      count: 61,
      color: tickColor,
      width: 1.2,
    );

    // Long radial bars carrying the fill.
    _paintRadialBars(
      canvas,
      centre,
      outer: r * 0.66,
      inner: r * 0.47,
      count: 46,
      width: r * 0.035,
    );

    // Halo hugging the centre well.
    final glow = innerGlow;
    if (glow != null) {
      canvas.drawCircle(
        centre,
        r * 0.50,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.10
          ..color = glow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }

    // Centre well.
    canvas.drawCircle(
      centre,
      r * 0.44,
      Paint()
        ..shader = RadialGradient(
          colors: [ringColor.withValues(alpha: 0.9), trackColor],
        ).createShader(Rect.fromCircle(center: centre, radius: r * 0.44)),
    );

    _paintNeedle(canvas, centre, r);
    _paintTopMarker(canvas, centre, r);
  }

  /// Thin white pointer from the middle out to the current angle.
  void _paintNeedle(Canvas canvas, Offset centre, double r) {
    final angle = GaugeGeometry.angleFor(_shownValue, maxValue);
    final tip = GaugeGeometry.pointOn(centre, r * 0.62, angle);
    final tail = GaugeGeometry.pointOn(centre, r * 0.10, angle);
    canvas.drawLine(
      tail,
      tip,
      Paint()
        ..color = const Color(0xFFF2F2F2)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Small triangle sitting at the top of the dial.
  void _paintTopMarker(Canvas canvas, Offset centre, double r) {
    final apex = GaugeGeometry.pointOn(centre, r * 1.02, -math.pi / 2);
    const half = 6.0;
    final path = Path()
      ..moveTo(apex.dx - half, apex.dy - half)
      ..lineTo(apex.dx + half, apex.dy - half)
      ..lineTo(apex.dx, apex.dy + half * 0.6)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF3FE0C8));
  }

  // ── Quality dial ──────────────────────────────────────────────────────────

  void _paintQuality(Canvas canvas, Offset centre, double r) {
    // Recessed outer ring.
    _paintBand(canvas, centre, r, r * 0.80, ringColor.withValues(alpha: 0.55));

    final arcRadius = r * 0.88;
    final arcRect = Rect.fromCircle(center: centre, radius: arcRadius);
    final stroke = r * 0.10;

    // Unfilled remainder of the dial.
    canvas.drawArc(
      arcRect,
      GaugeGeometry.startAngle,
      GaugeGeometry.sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = trackColor,
    );

    final sweep =
        GaugeGeometry.sweepAngle * (_shownValue / maxValue).clamp(0.0, 1.0);
    if (sweep > 0) {
      // Glow beneath the progress arc.
      canvas.drawArc(
        arcRect,
        GaugeGeometry.startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke * 1.4
          ..strokeCap = StrokeCap.round
          ..color = accent.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawArc(
        arcRect,
        GaugeGeometry.startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: GaugeGeometry.startAngle,
            endAngle: GaugeGeometry.startAngle + GaugeGeometry.sweepAngle,
            colors: [accent.withValues(alpha: 0.75), accent],
            transform: GradientRotation(GaugeGeometry.startAngle),
          ).createShader(arcRect),
      );

      // Knob riding the end of the arc.
      final knobAt = GaugeGeometry.pointOn(
        centre,
        arcRadius,
        GaugeGeometry.startAngle + sweep,
      );
      canvas.drawCircle(
        knobAt,
        stroke * 0.92,
        Paint()
          ..color = accent
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(knobAt, stroke * 0.78, Paint()..color = accent);
    }

    // Tick band and bar ring inside the arc.
    final bandOuter = r * 0.74;
    final bandInner = r * 0.60;
    _paintBand(canvas, centre, bandOuter, bandInner, trackColor);
    _paintTicks(
      canvas,
      centre,
      outer: bandOuter - r * 0.01,
      inner: bandInner + r * 0.02,
      count: 73,
      color: tickColor,
      width: 1.1,
    );
    _paintRadialBars(
      canvas,
      centre,
      outer: r * 0.56,
      inner: r * 0.46,
      count: 40,
      width: r * 0.022,
    );

    canvas.drawCircle(
      centre,
      r * 0.44,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: 0.16),
            trackColor.withValues(alpha: 0.95),
          ],
        ).createShader(Rect.fromCircle(center: centre, radius: r * 0.44)),
    );
  }

  // ── Shared pieces ─────────────────────────────────────────────────────────

  /// Fills the annulus between [outer] and [inner] radii.
  void _paintBand(
    Canvas canvas,
    Offset centre,
    double outer,
    double inner,
    Color color,
  ) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: centre, radius: outer))
      ..addOval(Rect.fromCircle(center: centre, radius: inner))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = color);
  }

  /// Fine graduations around the dial.
  void _paintTicks(
    Canvas canvas,
    Offset centre, {
    required double outer,
    required double inner,
    required int count,
    required Color color,
    required double width,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    for (final angle in GaugeGeometry.tickAngles(count)) {
      canvas.drawLine(
        GaugeGeometry.pointOn(centre, inner, angle),
        GaugeGeometry.pointOn(centre, outer, angle),
        paint,
      );
    }
  }

  /// Chunky radial strokes that fill up to the current value.
  void _paintRadialBars(
    Canvas canvas,
    Offset centre, {
    required double outer,
    required double inner,
    required int count,
    required double width,
  }) {
    final filledUpTo = (_shownValue / maxValue).clamp(0.0, 1.0);
    final glow = Paint()
      ..strokeWidth = width * 1.6
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final bar = Paint()
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < count; i++) {
      final t = i / (count - 1);
      if (t > filledUpTo) break;
      final angle = GaugeGeometry.startAngle + GaugeGeometry.sweepAngle * t;
      final a = GaugeGeometry.pointOn(centre, inner, angle);
      final b = GaugeGeometry.pointOn(centre, outer, angle);
      // Bars brighten towards the leading edge.
      bar.color = Color.lerp(
        accent.withValues(alpha: 0.55),
        accent,
        filledUpTo == 0 ? 0 : t / filledUpTo,
      )!;
      canvas.drawLine(a, b, glow);
      canvas.drawLine(a, b, bar);
    }
  }

  /// Numeric captions ringing the dial.
  void _paintLabels(
    Canvas canvas,
    Offset centre,
    double radius, {
    bool absolute = false,
  }) {
    if (tickLabels.isEmpty) return;
    final labelRadius = absolute ? radius : radius - radius * 0.07;
    var i = 0;
    for (final angle in GaugeGeometry.tickAngles(tickLabels.length)) {
      // The dial's midpoint caption is tinted to match the top marker.
      final isApex = tickLabels.length.isOdd && i == tickLabels.length ~/ 2;
      final tp = _labelCache.putIfAbsent(
        '${tickLabels[i]}#$isApex',
        () => TextPainter(
          text: TextSpan(
            text: tickLabels[i],
            style: isApex
                ? labelStyle.copyWith(color: const Color(0xFF3FE0C8))
                : labelStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
      );
      final at = GaugeGeometry.pointOn(centre, labelRadius, angle);
      tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant ScoreGaugePainter old) =>
      old.progress != progress ||
      old.value != value ||
      old.maxValue != maxValue ||
      old.variant != variant ||
      old.accent != accent ||
      old.tickColor != tickColor ||
      old.innerGlow != innerGlow ||
      old.ringAccent != ringAccent ||
      !identical(old.tickLabels, tickLabels);
}
