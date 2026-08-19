import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';

/// Strength / weakness tiles under "Organwise Score".
///
/// Tiles size themselves to a target width so the grid reflows from three
/// columns on a phone to more on a tablet without hard-coded breakpoints.
class OrganScoreGrid extends StatelessWidget {
  const OrganScoreGrid({
    super.key,
    required this.scores,
    required this.isStrength,
    this.onTap,
    this.showPercent = true,
  });

  final List<OrganScore> scores;
  final bool isStrength;
  final ValueChanged<OrganScore>? onTap;

  /// The condition screens print the bare figure; the genotype screens suffix
  /// it with a percent sign.
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 9.0;
        // Three across on a phone, widening to more on larger viewports.
        const target = 118.0;
        final columns = (constraints.maxWidth / target).floor().clamp(2, 6);
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final score in scores)
              SizedBox(
                width: width,
                child: _ScoreTile(
                  score: score,
                  isStrength: isStrength,
                  showPercent: showPercent,
                  onTap: onTap == null ? null : () => onTap!(score),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.score,
    required this.isStrength,
    this.onTap,
    required this.showPercent,
  });

  final OrganScore score;
  final bool isStrength;
  final bool showPercent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final border = isStrength
        ? AppColors.strengthBorder
        : AppColors.weaknessBorder;
    final fill = isStrength ? AppColors.strengthFill : AppColors.weaknessFill;
    final valueColor = isStrength ? AppColors.optimalBright : AppColors.low;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.2),
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Value and unit share a baseline, as in the design.
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      score.percent.toStringAsFixed(2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 15,
                        color: valueColor,
                      ),
                    ),
                  ),
                  if (showPercent) ...[
                    const SizedBox(width: 3),
                    Text(
                      '%',
                      style: AppTypography.bodyMuted.copyWith(
                        color: valueColor,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                score.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.monoLabel.copyWith(fontSize: 12.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
