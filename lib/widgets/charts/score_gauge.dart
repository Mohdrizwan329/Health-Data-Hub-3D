import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';
import '../painters/score_gauge_painter.dart';

/// Animated circular score dial.
///
/// The dial fills once on entry and re-animates from its previous reading when
/// the value changes, so switching gene or hormone reads as a transition rather
/// than a jump.
class ScoreGauge extends StatefulWidget {
  const ScoreGauge({
    super.key,
    required this.value,
    required this.accent,
    this.maxValue = 80,
    this.variant = ScoreGaugeVariant.genotype,
    this.tickLabels = const ['0', '20', '40', '60', '80'],
    this.size = 260,
    this.centerLabel,
    this.tickColor,
    this.innerGlow,
    this.ringAccent,
  });

  final double value;
  final double maxValue;
  final Color accent;
  final ScoreGaugeVariant variant;
  final List<String> tickLabels;
  final double size;

  /// Overrides the default `NN%` readout in the middle.
  final String? centerLabel;

  /// Graduation colour; the condition dial tints these with its accent.
  final Color? tickColor;

  /// Optional halo around the centre well.
  final Color? innerGlow;

  /// Rim colour when it differs from the bars.
  final Color? ringAccent;

  @override
  State<ScoreGauge> createState() => _ScoreGaugeState();
}

class _ScoreGaugeState extends State<ScoreGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late Animation<double> _fill;
  double _from = 0;

  @override
  void initState() {
    super.initState();
    _fill = _tween(0, widget.value);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ScoreGauge old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      // Continue from wherever the dial currently sits.
      _from = old.value * _controller.value;
      _fill = _tween(_from, widget.value);
      _controller
        ..reset()
        ..forward();
    }
  }

  Animation<double> _tween(double from, double to) => Tween(
    begin: from,
    end: to,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _fill,
          builder: (context, _) {
            final shown = _fill.value;
            return CustomPaint(
              painter: ScoreGaugePainter(
                // The painter multiplies value by progress, so feed it the
                // already-eased reading and a full progress.
                progress: 1,
                value: shown,
                maxValue: widget.maxValue,
                variant: widget.variant,
                accent: widget.accent,
                tickLabels: widget.tickLabels,
                labelStyle: AppTypography.gaugeTick,
                tickColor: widget.tickColor ?? const Color(0xFF3A3D4D),
                innerGlow: widget.innerGlow,
                ringAccent: widget.ringAccent,
              ),
              child: Center(
                child: Text(
                  widget.centerLabel ?? '${shown.round()}%',
                  style: AppTypography.gaugeValue,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
