import 'package:flutter/foundation.dart';

import 'impacted_parameter.dart';

/// One labelled segment of the semicircular needle gauge, and simultaneously
/// one row of that screen's RANGES legend.
@immutable
class GaugeBand {
  const GaugeBand({
    required this.label,
    required this.rangeText,
    required this.color,
  });

  /// Band name shown around the arc, e.g. `Optimal`.
  final String label;

  /// Threshold copy shown in the legend, e.g. `< 4.46 mcg/dL`.
  final String rangeText;
  final int color;

  factory GaugeBand.fromJson(Map<String, dynamic> json) => GaugeBand(
    label: json['label'] as String,
    rangeText: json['range_text'] as String? ?? '',
    color: int.parse((json['color'] as String).replaceFirst('#', '0xFF')),
  );
}

/// The per-organ score detail reached by tapping an organwise tile —
/// e.g. "SLC6A4 Heart Score".
@immutable
class OrganDetail {
  const OrganDetail({
    required this.organ,
    required this.score,
    required this.statusLabel,
    this.id = '',
    this.title,
    this.unit = '%',
    this.tint = 'green',
    required this.bands,
    required this.markerLabel,
    required this.markerValue,
    required this.impactedBy,
    required this.impactedParameters,
    required this.about,
  });

  final String id;
  final String organ;

  /// Overrides the derived heading, e.g. the standalone `Mentzer` screen.
  final String? title;

  /// Unit printed beside the reading.
  final String unit;

  /// Background wash key: `green`, `blue`, `crimson` or `amber`.
  final String tint;

  final double score;

  /// Qualitative word under the big number, e.g. `optimal`.
  final String statusLabel;
  final List<GaugeBand> bands;

  /// Outlined pill under the gauge, e.g. `Moderate` / `36.7`.
  final String markerLabel;
  final String markerValue;

  /// Subject of the impacted-parameters list, e.g. `LDL Cholesterol`.
  final String impactedBy;
  final List<ImpactedParameter> impactedParameters;
  final List<String> about;

  /// Sub-unit readings (a 0.05 tile) would round away to `0.1`, so they keep a
  /// second decimal; everything else prints as the design does.
  String get scoreLabel => formatReading(score);

  static String formatReading(double value) =>
      value.toStringAsFixed(value.abs() < 1 ? 2 : 1);

  factory OrganDetail.fromJson(Map<String, dynamic> json) => OrganDetail(
    id: json['id'] as String? ?? '',
    organ: json['organ'] as String,
    title: json['title'] as String?,
    unit: json['unit'] as String? ?? '%',
    tint: json['tint'] as String? ?? 'green',
    score: (json['score'] as num).toDouble(),
    statusLabel: json['status_label'] as String? ?? '',
    markerLabel: json['marker_label'] as String? ?? '',
    markerValue: json['marker_value'] as String? ?? '',
    impactedBy: json['impacted_by'] as String? ?? '',
    bands: (json['bands'] as List<dynamic>? ?? const [])
        .map((e) => GaugeBand.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    impactedParameters:
        (json['impacted_parameters'] as List<dynamic>? ?? const [])
            .map((e) => ImpactedParameter.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
    about: (json['about'] as List<dynamic>? ?? const []).cast<String>().toList(
      growable: false,
    ),
  );
}
