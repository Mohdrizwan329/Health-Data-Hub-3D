import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';
import 'status_pill.dart';

/// The "Blood Health Overview" card and its metrics table.
///
/// On narrow viewports the four columns would crush, so the table scrolls
/// horizontally inside the card rather than wrapping.
class BloodTable extends StatelessWidget {
  const BloodTable({
    super.key,
    required this.title,
    required this.subtitle,
    required this.metrics,
  });

  final String title;
  final String subtitle;
  final List<BloodMetric> metrics;

  static const _minTableWidth = 560.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B2036), Color(0xFF05080F)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.sectionTitle.copyWith(fontSize: 21)),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTypography.cardSubtitle),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final table = SizedBox(
                width: constraints.maxWidth < _minTableWidth
                    ? _minTableWidth
                    : constraints.maxWidth,
                child: _Table(metrics: metrics),
              );
              return constraints.maxWidth < _minTableWidth
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: table,
                    )
                  : table;
            },
          ),
        ],
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.metrics});

  final List<BloodMetric> metrics;

  // Shared across header and body so the columns line up.
  static const _columns = <int>[38, 18, 26, 18];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              for (final (i, label) in const [
                'METRICS',
                'VALUES',
                'HEALTHY RANGE',
                'STATUS',
              ].indexed)
                Expanded(
                  flex: _columns[i],
                  child: Text(
                    label,
                    textAlign: i == 0 ? TextAlign.start : TextAlign.center,
                    style: AppTypography.label.copyWith(letterSpacing: 0.6),
                  ),
                ),
            ],
          ),
        ),
        const Divider(color: AppColors.divider, height: 1),
        for (final metric in metrics) _Row(metric: metric),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.metric});

  final BloodMetric metric;

  Color get _statusColor => switch (metric.status) {
    MetricStatus.optimal || MetricStatus.normal => AppColors.optimalBright,
    MetricStatus.moderate => AppColors.moderate,
    MetricStatus.low => AppColors.low,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: _Table._columns[0],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.name,
                      style: AppTypography.cardTitle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      metric.description,
                      style: AppTypography.bodyMuted.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: _Table._columns[1],
                child: Text(
                  metric.value,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(fontSize: 16),
                ),
              ),
              Expanded(
                flex: _Table._columns[2],
                child: Text(
                  metric.healthyRange,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(fontSize: 14),
                ),
              ),
              Expanded(
                flex: _Table._columns[3],
                child: Center(
                  child: StatusPill(
                    label: metric.status.label,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.divider, height: 1),
      ],
    );
  }
}
