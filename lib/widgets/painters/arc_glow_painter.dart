import 'package:flutter/material.dart';

/// The bowed glow that sits beneath the condition dial.
class ArcGlowPainter extends CustomPainter {
  const ArcGlowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // A wide, shallow arc: the visible sliver of a much larger circle.
    final rect = Rect.fromLTWH(
      -size.width * 0.35,
      0,
      size.width * 1.7,
      size.height * 6,
    );
    for (final (width, blur, alpha) in const [
      (7.0, 22.0, 0.35),
      (3.0, 8.0, 0.75),
      (1.4, 0.0, 0.95),
    ]) {
      canvas.drawArc(
        rect,
        -3.0,
        0.28,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: alpha)
          ..maskFilter = blur == 0
              ? null
              : MaskFilter.blur(BlurStyle.normal, blur),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ArcGlowPainter old) => old.color != color;
}
