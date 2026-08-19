import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Paints the "levels during physical activity" chart.
///
/// A Catmull-Rom spline is stroked with a horizontal gradient so the line reads
/// green through the warm-up, amber at peak and red through recovery, with the
/// samples marked and a dashed reference line across the plot.
class ActivityChartPainter extends CustomPainter {
  ActivityChartPainter({
    required this.points,
    required this.xTicks,
    required this.yTicks,
    required this.reference,
    required this.progress,
    required this.labelStyle,
    this.strokeColors = const [
      Color(0xFF56E01B),
      Color(0xFFB8DF16),
      Color(0xFFF08A1E),
      Color(0xFFF2331F),
    ],
    this.dotColor = const Color(0xFF57D9E8),
  });

  /// Samples in data space: x across [xTicks], y across [yTicks].
  final List<Offset> points;
  final List<double> xTicks;
  final List<double> yTicks;

  /// Y value the dashed guide sits on.
  final double reference;

  /// Draw-in animation position, 0..1.
  final double progress;
  final TextStyle labelStyle;
  final List<Color> strokeColors;
  final Color dotColor;

  static const _gutterLeft = 34.0;
  static const _gutterBottom = 26.0;

  final Map<String, TextPainter> _labels = {};

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final plot = Rect.fromLTRB(
      _gutterLeft,
      6,
      size.width - 6,
      size.height - _gutterBottom,
    );

    final xMin = xTicks.first, xMax = xTicks.last;
    final yMin = yTicks.first, yMax = yTicks.last;

    Offset toCanvas(Offset p) => Offset(
      plot.left + plot.width * ((p.dx - xMin) / (xMax - xMin)),
      plot.bottom - plot.height * ((p.dy - yMin) / (yMax - yMin)),
    );

    _paintGrid(canvas, plot, toCanvas, xMin, xMax, yMin, yMax);
    _paintReference(canvas, plot, toCanvas);

    final canvasPoints = points.map(toCanvas).toList(growable: false);
    final line = _spline(canvasPoints);

    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, 0, plot.left + plot.width * progress, size.height),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = ui.Gradient.linear(
          Offset(plot.left, 0),
          Offset(plot.right, 0),
          strokeColors,
          _evenStops(strokeColors.length),
        ),
    );
    for (final p in canvasPoints) {
      canvas.drawCircle(p, 4.2, Paint()..color = dotColor);
      canvas.drawCircle(
        p,
        4.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: 0.65),
      );
    }
    canvas.restore();
  }

  List<double> _evenStops(int count) => [
    for (var i = 0; i < count; i++) i / (count - 1),
  ];

  void _paintGrid(
    Canvas canvas,
    Rect plot,
    Offset Function(Offset) toCanvas,
    double xMin,
    double xMax,
    double yMin,
    double yMax,
  ) {
    final dotted = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1;

    for (final x in xTicks) {
      final at = toCanvas(Offset(x, yMax));
      _dashedLine(
        canvas,
        Offset(at.dx, plot.top),
        Offset(at.dx, plot.bottom),
        dotted,
      );
      _text(canvas, _fmt(x), Offset(at.dx, plot.bottom + 13), center: true);
    }
    for (final y in yTicks) {
      final at = toCanvas(Offset(xMin, y));
      _text(
        canvas,
        _fmt(y),
        Offset(plot.left - 10, at.dy),
        alignRight: true,
        middle: true,
      );
    }
  }

  void _paintReference(Canvas canvas, Rect plot, Offset Function(Offset) to) {
    final y = to(Offset(xTicks.first, reference)).dy;
    _dashedLine(
      canvas,
      Offset(plot.left, y),
      Offset(plot.right, y),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..strokeWidth = 1.1,
      dash: 4,
      gap: 4,
    );
  }

  void _dashedLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint, {
    double dash = 3,
    double gap = 5,
  }) {
    final total = (b - a).distance;
    if (total <= 0) return;
    final step = (b - a) / total;
    var travelled = 0.0;
    while (travelled < total) {
      final end = math.min(travelled + dash, total);
      canvas.drawLine(a + step * travelled, a + step * end, paint);
      travelled = end + gap;
    }
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  void _text(
    Canvas canvas,
    String value,
    Offset at, {
    bool center = false,
    bool alignRight = false,
    bool middle = false,
  }) {
    final tp = _labels.putIfAbsent(
      value,
      () => TextPainter(
        text: TextSpan(text: value, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
    var dx = at.dx;
    if (center) dx -= tp.width / 2;
    if (alignRight) dx -= tp.width;
    tp.paint(canvas, Offset(dx, middle ? at.dy - tp.height / 2 : at.dy));
  }

  /// Catmull-Rom through [pts], emitted as cubic Béziers.
  Path _spline(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i == 0 ? pts[i] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant ActivityChartPainter old) =>
      old.progress != progress || !identical(old.points, points);
}
