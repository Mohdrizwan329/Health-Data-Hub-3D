import 'package:flutter/material.dart';

/// Paints the smooth area chart shown on the blood metric cards.
///
/// Points arrive normalised to 0..1; a Catmull-Rom spline is converted to cubic
/// segments so the curve stays smooth without overshooting the samples.
class SplineChartPainter extends CustomPainter {
  const SplineChartPainter({
    required this.samples,
    required this.color,
    required this.progress,
  });

  /// Normalised values, oldest first.
  final List<double> samples;
  final Color color;

  /// Draw-in animation position, 0..1.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2 || progress <= 0) return;

    final points = <Offset>[
      for (var i = 0; i < samples.length; i++)
        Offset(
          size.width * i / (samples.length - 1),
          size.height * (1 - samples[i].clamp(0.0, 1.0)),
        ),
    ];

    final line = _spline(points);

    // Close the path down to the baseline for the gradient fill.
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.save();
    // Reveal left-to-right as the card animates in.
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.55),
            color.withValues(alpha: 0.10),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0, 0.65, 1],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
    canvas.restore();
  }

  /// Catmull-Rom through [pts], emitted as cubic Béziers.
  Path _spline(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i == 0 ? pts[i] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;
      // Standard Catmull-Rom to Bézier control point conversion.
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant SplineChartPainter old) =>
      old.progress != progress ||
      old.color != color ||
      !identical(old.samples, samples);
}
