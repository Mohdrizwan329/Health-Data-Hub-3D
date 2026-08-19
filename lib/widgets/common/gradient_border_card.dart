import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Rounded container drawn with a gradient rim.
///
/// Implemented as two stacked containers rather than a painter, so the child
/// clips naturally and the rim participates in normal layout.
class GradientBorderCard extends StatelessWidget {
  const GradientBorderCard({
    super.key,
    required this.child,
    this.colors = const [AppColors.accentCyan, AppColors.accentViolet],
    this.borderWidth = 1.4,
    this.radius = 20,
    this.fill = Colors.black,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final List<Color> colors;
  final double borderWidth;
  final double radius;
  final Color fill;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(radius - borderWidth),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
