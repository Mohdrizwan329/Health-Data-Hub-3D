import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';
import '../painters/needle_gauge_painter.dart';

/// Animated semicircular banded dial used on the organ detail screen.
class NeedleGauge extends StatefulWidget {
  const NeedleGauge({
    super.key,
    required this.fraction,
    required this.segmentColors,
    required this.segmentLabels,
    this.height = 200,
  });

  /// Needle position across the whole arc, 0..1.
  final double fraction;
  final List<Color> segmentColors;
  final List<String> segmentLabels;
  final double height;

  @override
  State<NeedleGauge> createState() => _NeedleGaugeState();
}

class _NeedleGaugeState extends State<NeedleGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
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
            painter: NeedleGaugePainter(
              progress: Curves.easeOutBack
                  .transform(_controller.value.clamp(0.0, 1.0))
                  .clamp(0.0, 1.0),
              fraction: widget.fraction,
              segmentColors: widget.segmentColors,
              segmentLabels: widget.segmentLabels,
              labelStyle: AppTypography.gaugeTick,
            ),
          ),
        ),
      ),
    );
  }
}
