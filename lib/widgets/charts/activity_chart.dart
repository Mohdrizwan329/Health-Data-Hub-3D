import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';
import '../painters/activity_chart_painter.dart';

/// The activity chart card: title, rotated axis caption, plot and legend.
class ActivityChart extends StatefulWidget {
  const ActivityChart({super.key, required this.series});

  final ActivitySeries series;

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final series = widget.series;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.optimalBright.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            series.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sectionTitle.copyWith(fontSize: 11.5),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 224,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Rotated caption running up the y axis.
                // Fixed footprint so the rotated caption cannot overflow the
                // plot's height and get clipped.
                SizedBox(
                  width: 20,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: Text(
                        series.axisLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.cardTitle.copyWith(fontSize: 12.5),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) => CustomPaint(
                              painter: ActivityChartPainter(
                                points: series.points,
                                xTicks: series.xTicks,
                                yTicks: series.yTicks,
                                reference: series.reference,
                                progress: Curves.easeOutCubic.transform(
                                  _controller.value,
                                ),
                                labelStyle: AppTypography.bodyMuted.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: _Legend(entries: series.legend),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.entries});

  final List<ActivityPhase> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Color(entry.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.label,
                    style: AppTypography.bodyMuted.copyWith(
                      fontSize: 8.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
