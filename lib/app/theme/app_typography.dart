import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type ramp for the hub.
///
/// Three families carry the design: a wide techno face for section headings and
/// gauge readouts, a humanist sans for body copy, and a mono face for the
/// organwise score labels.
abstract final class AppFonts {
  static const display = 'Orbitron';
  static const body = 'NunitoSans';
  static const mono = 'ShareTechMono';
}

abstract final class AppTypography {
  /// Screen and section headings — "Gene-to-Health Overview", "RANGES".
  static const sectionTitle = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
    height: 1.2,
  );

  static const screenTitle = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  /// Centred label above a gauge, e.g. "SLC6A4 / Genotype Score".
  static const gaugeCaption = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 21,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.35,
  );

  /// Large percentage rendered in the middle of a gauge.
  static const gaugeValue = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1,
  );

  static const cardTitle = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const cardSubtitle = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.35,
  );

  static const body = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.55,
  );

  static const bodyMuted = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const label = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  /// Numeric readout on the metric cards, e.g. "80 mg / dL".
  static const metricValue = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1,
  );

  static const metricUnit = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Organ name inside a strength / weakness tile.
  static const monoLabel = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 14,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  /// Tick numbers drawn around a gauge.
  static const gaugeTick = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
