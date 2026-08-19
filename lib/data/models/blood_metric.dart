import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Status wording used by the blood table and the metric-card chips.
enum MetricStatus {
  optimal,
  normal,
  moderate,
  low;

  static MetricStatus fromJson(String? value) => switch (value) {
    'normal' => normal,
    'moderate' => moderate,
    'low' => low,
    _ => optimal,
  };

  String get label => switch (this) {
    optimal => 'Optimal',
    normal => 'Normal',
    moderate => 'Moderate',
    low => 'Low',
  };

  /// Whether the reading sits inside its healthy window.
  bool get isHealthy => this == optimal || this == normal;
}

/// A row of the "Blood Health Overview" table.
@immutable
class BloodMetric {
  const BloodMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.healthyRange,
    required this.status,
  });

  final String id;
  final String name;
  final String description;

  /// Pre-formatted display value, e.g. `14.5 g/dL`.
  final String value;
  final String healthyRange;
  final MetricStatus status;

  factory BloodMetric.fromJson(Map<String, dynamic> json) => BloodMetric(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    value: json['value'] as String,
    healthyRange: json['healthy_range'] as String? ?? '',
    status: MetricStatus.fromJson(json['status'] as String?),
  );
}

/// A callout chip floating over the blood-cell artwork.
@immutable
class MetricChip {
  const MetricChip({
    required this.title,
    required this.value,
    required this.unit,
    required this.alignment,
    this.scale = 1.0,
  });

  final String title;

  /// Headline number, e.g. `4.8`.
  final String value;
  final String unit;

  /// Position over the artwork, expressed in `Alignment` coordinates so the
  /// chips track the illustration as the viewport resizes.
  final Alignment alignment;

  /// Relative size, letting far-away chips render smaller.
  final double scale;

  factory MetricChip.fromJson(Map<String, dynamic> json) => MetricChip(
    title: json['title'] as String,
    value: json['value'] as String? ?? '',
    unit: json['unit'] as String? ?? '',
    alignment: Alignment(
      (json['x'] as num?)?.toDouble() ?? 0,
      (json['y'] as num?)?.toDouble() ?? 0,
    ),
    scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
  );
}

/// A large themed card such as "Blood Sugar" or "Blood Pressure".
@immutable
class TrendCard {
  const TrendCard({
    required this.id,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.trend,
    required this.accent,
    this.secondaryValue,
  });

  final String id;
  final String title;
  final String value;

  /// Second half of a paired reading, e.g. the diastolic `72`.
  final String? secondaryValue;
  final String unit;
  final MetricStatus status;

  /// Normalised 0..1 samples driving the spline chart.
  final List<double> trend;
  final int accent;

  factory TrendCard.fromJson(Map<String, dynamic> json) => TrendCard(
    id: json['id'] as String,
    title: json['title'] as String,
    value: json['value'] as String,
    secondaryValue: json['secondary_value'] as String?,
    unit: json['unit'] as String? ?? '',
    status: MetricStatus.fromJson(json['status'] as String?),
    trend: (json['trend'] as List<dynamic>? ?? const [])
        .map((e) => (e as num).toDouble())
        .toList(growable: false),
    accent: switch (json['accent']) {
      final String hex => int.parse(hex.replaceFirst('#', '0xFF')),
      _ => 0xFFFFA726,
    },
  );
}
