import 'package:flutter/material.dart';

/// A soft radial wash of colour placed behind the page content.
@immutable
class GlowSpot {
  const GlowSpot({
    required this.alignment,
    required this.color,
    required this.radius,
    this.intensity = 1.0,
  });

  /// Centre of the wash in `Alignment` coordinates.
  final Alignment alignment;
  final Color color;

  /// Radius as a fraction of the canvas's longest side.
  final double radius;

  /// Opacity multiplier, letting one spot sit behind another.
  final double intensity;
}

/// Paints the layered background glows that give each mode its tint.
///
/// Drawing these directly is cheaper than stacking several blurred containers,
/// and keeps the effect resolution-independent.
class AmbientGlowPainter extends CustomPainter {
  const AmbientGlowPainter({required this.spots, required this.base});

  final List<GlowSpot> spots;

  /// Flat colour painted under every spot.
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = base);

    final longest = size.longestSide;
    for (final spot in spots) {
      final centre = spot.alignment.withinRect(bounds);
      final radius = longest * spot.radius;
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              spot.color.withValues(alpha: 0.55 * spot.intensity),
              spot.color.withValues(alpha: 0.14 * spot.intensity),
              spot.color.withValues(alpha: 0.0),
            ],
            // Weighted toward the centre so the wash falls off quickly and the
            // page stays predominantly black, as in the design.
            stops: const [0, 0.35, 1],
          ).createShader(Rect.fromCircle(center: centre, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant AmbientGlowPainter old) =>
      old.base != base || !identical(old.spots, spots);
}
