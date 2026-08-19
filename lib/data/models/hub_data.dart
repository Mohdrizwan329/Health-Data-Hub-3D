import 'package:flutter/foundation.dart';

import 'art_hotspot.dart';
import 'blood_metric.dart';
import 'gene_marker.dart';
import 'health_conditions.dart';
import 'hormone_marker.dart';
import 'marker_template.dart';
import 'organ_condition.dart';
import 'organ_detail.dart';
import 'score_band.dart';

/// An entry in one of the dropdown selection sheets
/// ("Hormone Regulation Score", "Organ Metrics", "Blood Metrics", …).
@immutable
class HubSection {
  const HubSection({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.icon,
  });

  final String id;
  final String title;
  final String subtitle;

  /// Key into the icon registry, so JSON stays free of Dart symbols.
  final String? icon;

  factory HubSection.fromJson(Map<String, dynamic> json) => HubSection(
    id: json['id'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String? ?? '',
    icon: json['icon'] as String?,
  );
}

/// Everything behind the phenotype (blood) screen.
@immutable
class PhenotypeData {
  const PhenotypeData({
    required this.overallQuality,
    required this.chips,
    required this.trendCards,
    required this.metrics,
    required this.sections,
    required this.overviewTitle,
    required this.overviewSubtitle,
  });

  /// Percentage driving the "Overall Blood Quality" gauge.
  final double overallQuality;
  final List<MetricChip> chips;
  final List<TrendCard> trendCards;
  final List<BloodMetric> metrics;
  final List<HubSection> sections;
  final String overviewTitle;
  final String overviewSubtitle;

  ScoreBand get band => ScoreBand.forScore(overallQuality);

  factory PhenotypeData.fromJson(Map<String, dynamic> json) => PhenotypeData(
    overallQuality: (json['overall_quality'] as num).toDouble(),
    overviewTitle: json['overview_title'] as String? ?? '',
    overviewSubtitle: json['overview_subtitle'] as String? ?? '',
    chips: (json['chips'] as List<dynamic>? ?? const [])
        .map((e) => MetricChip.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    trendCards: (json['trend_cards'] as List<dynamic>? ?? const [])
        .map((e) => TrendCard.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    metrics: (json['metrics'] as List<dynamic>? ?? const [])
        .map((e) => BloodMetric.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    sections: (json['sections'] as List<dynamic>? ?? const [])
        .map((e) => HubSection.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );
}

/// Everything behind the genotype screens (genes + hormones).
@immutable
class GenotypeData {
  const GenotypeData({
    required this.genes,
    required this.hormones,
    required this.sections,
    required this.ranges,
  });

  final List<GeneMarker> genes;
  final List<HormoneMarker> hormones;
  final List<HubSection> sections;
  final List<RangeBand> ranges;

  GeneMarker geneById(String id) =>
      genes.firstWhere((g) => g.id == id, orElse: () => genes.first);

  HormoneMarker hormoneById(String id) =>
      hormones.firstWhere((h) => h.id == id, orElse: () => hormones.first);

  factory GenotypeData.fromJson(Map<String, dynamic> json) => GenotypeData(
    genes: (json['genes'] as List<dynamic>? ?? const [])
        .map((e) => GeneMarker.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    hormones: (json['hormones'] as List<dynamic>? ?? const [])
        .map((e) => HormoneMarker.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    sections: (json['sections'] as List<dynamic>? ?? const [])
        .map((e) => HubSection.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    ranges: (json['ranges'] as List<dynamic>? ?? const [])
        .map((e) => RangeBand.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );
}

/// Aggregate root loaded once from local JSON and shared by every screen.
@immutable
class HubData {
  const HubData({
    required this.genotype,
    required this.phenotype,
    required this.conditions,
    required this.health,
    required this.markers,
    required this.markerTemplate,
  });

  final GenotypeData genotype;
  final PhenotypeData phenotype;

  /// Per-organ condition screens reached from the Organ Metrics section.
  final List<OrganCondition> conditions;

  /// The whole-body Health Conditions Overview.
  final HealthConditions health;

  /// Standalone marker detail screens, reached from a risk assessment row.
  final List<OrganDetail> markers;

  /// Fills in detail screens for markers the sample data does not spell out.
  final MarkerTemplate markerTemplate;

  OrganDetail? markerNamed(String name) {
    for (final marker in markers) {
      if (marker.organ.toLowerCase() == name.toLowerCase()) return marker;
    }
    return null;
  }

  /// The detail screen behind any marker, strength or weakness label.
  ///
  /// Bespoke payloads win; everything else is built from [markerTemplate] so a
  /// tile never leads to a dead end.
  OrganDetail detailFor(String name, {double? score, String? valueLabel}) =>
      markerNamed(name) ??
      markerTemplate.build(name, score: score, valueLabel: valueLabel);

  /// Resolves what a hero-artwork hotspot points at.
  Object? targetOf(HotspotTarget target) => switch (target.kind) {
    HotspotKind.condition => conditionById(target.value),
    HotspotKind.marker => detailFor(target.value, score: 36.7),
  };

  OrganCondition? conditionById(String id) {
    for (final condition in conditions) {
      if (condition.id == id) return condition;
    }
    return null;
  }

  factory HubData.fromJson(Map<String, dynamic> json) => HubData(
    genotype: GenotypeData.fromJson(json['genotype'] as Map<String, dynamic>),
    phenotype: PhenotypeData.fromJson(
      json['phenotype'] as Map<String, dynamic>,
    ),
    conditions: (json['conditions'] as List<dynamic>? ?? const [])
        .map((e) => OrganCondition.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    health: HealthConditions.fromJson(json['health'] as Map<String, dynamic>),
    markers: (json['markers'] as List<dynamic>? ?? const [])
        .map((e) => OrganDetail.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    markerTemplate: MarkerTemplate.fromJson(
      json['marker_template'] as Map<String, dynamic>? ?? const {},
    ),
  );
}
