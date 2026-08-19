import 'package:flutter/material.dart';

import '../painters/spline_chart_painter.dart';

/// Smooth area chart that draws itself in from the left on first build.
class SplineChart extends StatefulWidget {
  const SplineChart({
    super.key,
    required this.samples,
    required this.color,
    this.height = 78,
  });

  final List<double> samples;
  final Color color;
  final double height;

  @override
  State<SplineChart> createState() => _SplineChartState();
}

class _SplineChartState extends State<SplineChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: SplineChartPainter(
              samples: widget.samples,
              color: widget.color,
              progress: Curves.easeOutCubic.transform(_controller.value),
            ),
          ),
        ),
      ),
    );
  }
}
