import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';

/// The "Chronic … Disease Risk Assessment" rows.
///
/// Each row is tinted by its tone: a seal-check glyph on the left, the marker
/// name and reference range in the middle, and a large reading on the right.
class RiskAssessmentList extends StatelessWidget {
  const RiskAssessmentList({super.key, required this.markers, this.onTap});

  final List<RiskMarker> markers;

  /// Called when a row has a detail screen behind it.
  final ValueChanged<RiskMarker>? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final marker in markers)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RiskRow(
              marker: marker,
              onTap: onTap == null ? null : () => onTap!(marker),
            ),
          ),
      ],
    );
  }
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({required this.marker, this.onTap});

  final RiskMarker marker;
  final VoidCallback? onTap;

  Color get _accent => switch (marker.tone) {
    RiskTone.amber => AppColors.riskAmber,
    RiskTone.green => AppColors.riskGreen,
    RiskTone.red => AppColors.riskRed,
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.85)),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [accent.withValues(alpha: 0.16), Colors.black],
              stops: const [0, 0.75],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Icon(Icons.verified_outlined, color: accent, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      marker.name,
                      style: AppTypography.cardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      marker.range,
                      style: AppTypography.cardSubtitle.copyWith(
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                marker.value,
                style: AppTypography.sectionTitle.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
