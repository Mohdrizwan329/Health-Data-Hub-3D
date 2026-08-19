import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';
import '../painters/mini_meter_painter.dart';

/// The compact score card that sits beside the ABOUT copy.
class ScoreSummaryCard extends StatelessWidget {
  const ScoreSummaryCard({super.key, required this.summary, this.artAsset});

  final ScoreSummary summary;

  /// Small illustration shown between the caption and the reading.
  final String? artAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.45)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1020), Color(0xFF05070E)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            summary.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            summary.subtitle,
            style: AppTypography.bodyMuted.copyWith(fontSize: 9.5),
          ),
          if (artAsset != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Image.asset(
                  artAsset!,
                  height: 74,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            )
          else
            const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF121A33),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                  child: CustomPaint(
                    painter: MiniMeterPainter(
                      fraction: summary.percent / 100,
                      color: AppColors.accentCyan,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '0%',
                      style: AppTypography.bodyMuted.copyWith(fontSize: 8.5),
                    ),
                    Expanded(
                      child: Text(
                        '${summary.percent.toStringAsFixed(0)}%',
                        textAlign: TextAlign.center,
                        style: AppTypography.metricValue.copyWith(fontSize: 26),
                      ),
                    ),
                    Text(
                      '100%',
                      style: AppTypography.bodyMuted.copyWith(fontSize: 8.5),
                    ),
                  ],
                ),
                Text(
                  summary.caption,
                  style: AppTypography.bodyMuted.copyWith(fontSize: 8.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
