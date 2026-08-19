import 'package:flutter/foundation.dart';

import 'art_hotspot.dart';
import 'organ_score.dart';

/// One row of the "Chronic … Disease Risk Assessment" list.
@immutable
class RiskMarker {
  const RiskMarker({
    required this.name,
    required this.range,
    required this.value,
    required this.tone,
  });

  final String name;

  /// Reference text under the name, e.g. `12.3 - 15.5 secs`.
  final String range;

  /// Pre-formatted reading, e.g. `16.7`.
  final String value;

  /// Which of the three accent tones the row uses.
  final RiskTone tone;

  factory RiskMarker.fromJson(Map<String, dynamic> json) => RiskMarker(
    name: json['name'] as String,
    range: json['range'] as String? ?? '',
    value: json['value'] as String,
    tone: RiskTone.fromJson(json['tone'] as String?),
  );
}

/// Accent tones used by the risk rows.
enum RiskTone {
  amber,
  green,
  red;

  static RiskTone fromJson(String? value) => switch (value) {
    'green' => green,
    'red' => red,
    _ => amber,
  };
}

/// A per-organ condition screen: hero artwork, condition dial, guidance,
/// strengths / weaknesses and the risk assessment list.
@immutable
class OrganCondition {
  const OrganCondition({
    required this.id,
    required this.organ,
    required this.title,
    required this.conditionTitle,
    required this.score,
    required this.heroAsset,
    required this.thumbAsset,
    this.hotspots = const [],
    required this.recommendationTitle,
    required this.recommendations,
    required this.riskTitle,
    required this.risks,
    this.numbered = true,
    this.strengths = const [],
    this.weaknesses = const [],
  });

  final String id;
  final String organ;

  /// Screen heading, e.g. `Heart Conditions Overview`.
  final String title;

  /// Caption above the dial, e.g. `Heart Attack (Myocardial Infarction)`.
  final String conditionTitle;
  final double score;

  final String heroAsset;
  final String thumbAsset;

  /// "View in Details" links baked into the hero artwork.
  final List<ArtHotspot> hotspots;

  /// Bold intro paragraph of the guidance card.
  final String recommendationTitle;
  final List<String> recommendations;

  /// Whether the guidance renders as a numbered or bulleted list.
  final bool numbered;

  final String riskTitle;
  final List<RiskMarker> risks;
  final List<OrganScore> strengths;
  final List<OrganScore> weaknesses;

  String get scoreLabel => '${score.toStringAsFixed(score % 1 == 0 ? 0 : 1)}%';

  factory OrganCondition.fromJson(Map<String, dynamic> json) => OrganCondition(
    id: json['id'] as String,
    organ: json['organ'] as String,
    title: json['title'] as String,
    conditionTitle: json['condition_title'] as String? ?? '',
    score: (json['score'] as num).toDouble(),
    heroAsset: json['hero_asset'] as String,
    thumbAsset: json['thumb_asset'] as String? ?? json['hero_asset'] as String,
    hotspots: ArtHotspot.listFrom(json['hotspots']),
    recommendationTitle: json['recommendation_title'] as String? ?? '',
    numbered: json['numbered'] as bool? ?? true,
    recommendations: (json['recommendations'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toList(growable: false),
    riskTitle: json['risk_title'] as String? ?? '',
    risks: (json['risks'] as List<dynamic>? ?? const [])
        .map((e) => RiskMarker.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    strengths: (json['strengths'] as List<dynamic>? ?? const [])
        .map((e) => OrganScore.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    weaknesses: (json['weaknesses'] as List<dynamic>? ?? const [])
        .map((e) => OrganScore.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );
}
