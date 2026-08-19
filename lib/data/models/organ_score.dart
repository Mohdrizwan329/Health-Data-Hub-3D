import 'package:flutter/foundation.dart';

/// One tile in the "Organwise Score" strengths / weaknesses grid.
@immutable
class OrganScore {
  const OrganScore({required this.label, required this.percent});

  final String label;
  final double percent;

  /// Rendered with two decimals to match the design ("76.96 %").
  String get formatted => '${percent.toStringAsFixed(2)} %';

  factory OrganScore.fromJson(Map<String, dynamic> json) => OrganScore(
    label: json['label'] as String,
    percent: (json['percent'] as num).toDouble(),
  );
}
