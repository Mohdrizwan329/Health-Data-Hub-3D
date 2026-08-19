import 'package:flutter/foundation.dart';

import 'impacted_parameter.dart';
import 'organ_detail.dart';
import 'organ_score.dart';
import 'score_band.dart';

/// A gene shown in the genotype world (SLC6A4, COMT, OXTR, DRD4, …).
@immutable
class GeneMarker {
  const GeneMarker({
    required this.id,
    required this.symbol,
    required this.fullName,
    required this.summary,
    required this.score,
    required this.narrative,
    required this.about,
    this.strengths = const [],
    this.weaknesses = const [],
    this.impactedParameters = const [],
    this.organDetails = const [],
    this.accent = 0xFF5DD400,
  });

  final String id;

  /// Gene symbol, e.g. `SLC6A4`.
  final String symbol;

  /// Expanded name, e.g. `Serotonin Transporter Gene`.
  final String fullName;

  /// One-line description used in the selection sheet.
  final String summary;

  /// Genotype score as a percentage.
  final double score;

  /// Paragraphs interpreting the score for the user.
  final List<String> narrative;

  /// Longer "ABOUT" explainer paragraphs.
  final List<String> about;

  final List<OrganScore> strengths;
  final List<OrganScore> weaknesses;
  final List<ImpactedParameter> impactedParameters;

  /// Per-organ breakdowns reached by tapping an organwise tile.
  final List<OrganDetail> organDetails;

  /// Colour used for this gene's chip and icon glyph.
  final int accent;

  ScoreBand get band => ScoreBand.forScore(score);

  /// Detail page for [organ], or null when the design has no drill-down.
  OrganDetail? detailFor(String organ) {
    for (final d in organDetails) {
      if (d.organ.toLowerCase() == organ.toLowerCase()) return d;
    }
    return null;
  }

  /// `66%` — the form used in headings and the gauge centre.
  String get scoreLabel => '${score.toStringAsFixed(score % 1 == 0 ? 0 : 1)}%';

  factory GeneMarker.fromJson(Map<String, dynamic> json) => GeneMarker(
    id: json['id'] as String,
    symbol: json['symbol'] as String,
    fullName: json['full_name'] as String? ?? '',
    summary: json['summary'] as String? ?? '',
    score: (json['score'] as num).toDouble(),
    narrative: (json['narrative'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toList(growable: false),
    about: (json['about'] as List<dynamic>? ?? const []).cast<String>().toList(
      growable: false,
    ),
    strengths: (json['strengths'] as List<dynamic>? ?? const [])
        .map((e) => OrganScore.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    weaknesses: (json['weaknesses'] as List<dynamic>? ?? const [])
        .map((e) => OrganScore.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    impactedParameters:
        (json['impacted_parameters'] as List<dynamic>? ?? const [])
            .map((e) => ImpactedParameter.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
    organDetails: (json['organ_details'] as List<dynamic>? ?? const [])
        .map((e) => OrganDetail.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    accent: switch (json['accent']) {
      final String hex => int.parse(hex.replaceFirst('#', '0xFF')),
      _ => 0xFF5DD400,
    },
  );
}
