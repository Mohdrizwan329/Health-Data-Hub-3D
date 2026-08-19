import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Floating label pinned over the artwork, naming a gene or hormone.
///
/// Selection is expressed by the rim lighting up and the chip lifting slightly,
/// so the active marker is obvious without moving anything else on screen.
class MarkerChip extends StatelessWidget {
  const MarkerChip({
    super.key,
    required this.title,
    required this.selected,
    required this.accent,
    this.subtitle,
    this.scale = 1,
    this.onTap,
    this.maxWidth = 168,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final Color accent;

  /// Depth cue — distant markers render smaller, as in the design.
  final double scale;
  final VoidCallback? onTap;

  /// Chips wrap rather than growing to fit long gene names, which would
  /// otherwise push them off the stage.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final rim = selected ? accent : Colors.white.withValues(alpha: 0.18);

    return Semantics(
      button: true,
      selected: selected,
      label: subtitle == null ? title : '$title, $subtitle',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          scale: selected ? scale * 1.06 : scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            constraints: BoxConstraints(maxWidth: maxWidth * scale),
            padding: EdgeInsets.symmetric(
              horizontal: 11 * scale,
              vertical: 8 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: selected ? 0.62 : 0.55),
              borderRadius: BorderRadius.circular(14 * scale),
              border: Border.all(color: rim, width: selected ? 1.6 : 1),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.45),
                        blurRadius: 18,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.screenTitle.copyWith(
                    fontSize: 14.5 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMuted.copyWith(
                      fontSize: 9.5 * scale,
                      height: 1.2,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Callout pinned over the blood artwork, carrying a reading.
class CalloutChip extends StatelessWidget {
  const CalloutChip({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.scale = 1,
    this.anchor = Alignment.centerRight,
    this.maxWidth = 170,
  });

  final String title;
  final String value;
  final String unit;
  final double scale;

  /// Keeps long metric names wrapping instead of spanning the whole stage.
  final double maxWidth;

  /// Which edge carries the small dot tying the chip to a cell.
  final Alignment anchor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: anchor,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth * scale),
          padding: EdgeInsets.symmetric(
            horizontal: 11 * scale,
            vertical: 9 * scale,
          ),
          decoration: BoxDecoration(
            // Opaque enough to read cleanly over the busy artwork behind it.
            color: Colors.black.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 11.5 * scale,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 4 * scale),
              // Long units ("million/µL") must not push the chip past its
              // max width, so the reading scales down instead of overflowing.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: AppTypography.metricValue.copyWith(
                        fontSize: 21 * scale,
                      ),
                    ),
                    SizedBox(width: 4 * scale),
                    Text(
                      unit,
                      style: AppTypography.metricUnit.copyWith(
                        fontSize: 11 * scale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Anchor dot overlapping the rim.
        Positioned(
          right: anchor == Alignment.centerRight ? -6 * scale : null,
          left: anchor == Alignment.centerLeft ? -6 * scale : null,
          bottom: anchor == Alignment.bottomRight ? 8 * scale : null,
          child: Container(
            width: 13 * scale,
            height: 13 * scale,
            decoration: const BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
