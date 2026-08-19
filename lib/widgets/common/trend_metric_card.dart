import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';
import '../charts/spline_chart.dart';

/// Themed metric card — glyph tile, reading, status chip and a trend spline.
class TrendMetricCard extends StatelessWidget {
  const TrendMetricCard({super.key, required this.card});

  final TrendCard card;

  @override
  Widget build(BuildContext context) {
    final accent = Color(card.accent);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.85), width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.22), Colors.black],
          stops: const [0, 0.75],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(_glyph, color: accent, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    card.title,
                    maxLines: 2,
                    style: AppTypography.cardTitle.copyWith(fontSize: 14.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _Reading(card: card),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                card.status.label,
                style: AppTypography.label.copyWith(color: accent),
              ),
            ),
            const SizedBox(height: 10),
            SplineChart(samples: card.trend, color: accent, height: 74),
          ],
        ),
      ),
    );
  }

  IconData get _glyph => switch (card.id) {
    'sugar' => Icons.bloodtype_outlined,
    'pressure' => Icons.monitor_heart_outlined,
    _ => Icons.show_chart,
  };
}

class _Reading extends StatelessWidget {
  const _Reading({required this.card});

  final TrendCard card;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(card.value, style: AppTypography.metricValue),
          if (card.secondaryValue != null) ...[
            Text(
              ' / ${card.secondaryValue}',
              style: AppTypography.metricValue.copyWith(
                fontSize: 24,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(width: 6),
          Text(card.unit, style: AppTypography.metricUnit),
        ],
      ),
    );
  }
}
