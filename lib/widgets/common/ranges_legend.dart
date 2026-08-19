import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';

/// The RANGES block: a glowing swatch beside a title and explanation.
///
/// Rows flow two-up on wide viewports and stack on narrow ones.
class RangesLegend extends StatelessWidget {
  const RangesLegend({super.key, required this.bands});

  final List<RangeBand> bands;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoUp = constraints.maxWidth >= 330;
        const gap = 18.0;
        final itemWidth = twoUp
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final band in bands)
              SizedBox(
                width: itemWidth,
                child: _RangeRow(band: band),
              ),
          ],
        );
      },
    );
  }
}

class _RangeRow extends StatelessWidget {
  const _RangeRow({required this.band});

  final RangeBand band;

  @override
  Widget build(BuildContext context) {
    final color = band.band.color;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.55),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(band.title, style: AppTypography.cardTitle),
              const SizedBox(height: 4),
              Text(band.description, style: AppTypography.bodyMuted),
            ],
          ),
        ),
      ],
    );
  }
}
