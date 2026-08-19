import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The three-way banding the design uses everywhere a score is shown.
///
/// Thresholds mirror the RANGES legend: High 80–100, Moderate 50–79, Low <50.
enum ScoreBand {
  low,
  moderate,
  high;

  static ScoreBand forScore(double percent) => switch (percent) {
    >= 80 => high,
    >= 50 => moderate,
    _ => low,
  };

  static ScoreBand fromJson(String? value) => switch (value) {
    'high' => high,
    'low' => low,
    _ => moderate,
  };

  String get label => switch (this) {
    high => 'High',
    moderate => 'Moderate',
    low => 'Low',
  };

  /// Primary colour used for arcs, borders and value text.
  Color get color => switch (this) {
    high => AppColors.optimalBright,
    moderate => AppColors.moderate,
    low => AppColors.low,
  };

  /// Dimmer companion used for gradient tails and glows.
  Color get deepColor => switch (this) {
    high => AppColors.optimalDeep,
    moderate => AppColors.moderateDeep,
    low => AppColors.critical,
  };
}

/// A single row of the RANGES legend.
@immutable
class RangeBand {
  const RangeBand({
    required this.band,
    required this.title,
    required this.description,
  });

  final ScoreBand band;
  final String title;
  final String description;

  factory RangeBand.fromJson(Map<String, dynamic> json) => RangeBand(
    band: ScoreBand.fromJson(json['band'] as String?),
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
  );
}
