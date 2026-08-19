import 'package:flutter/foundation.dart';

import 'score_band.dart';

/// A hormone shown in the "Hormone Regulation Score" view.
@immutable
class HormoneMarker {
  const HormoneMarker({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.score,
    required this.narrative,
    required this.about,
    this.accent = 0xFFFFD400,
  });

  final String id;
  final String name;

  /// Parenthetical role, e.g. `Motivation & Focus Hormone`.
  final String subtitle;
  final double score;
  final List<String> narrative;
  final List<String> about;
  final int accent;

  ScoreBand get band => ScoreBand.forScore(score);

  String get scoreLabel => '${score.toStringAsFixed(score % 1 == 0 ? 0 : 1)}%';

  factory HormoneMarker.fromJson(Map<String, dynamic> json) => HormoneMarker(
    id: json['id'] as String,
    name: json['name'] as String,
    subtitle: json['subtitle'] as String? ?? '',
    score: (json['score'] as num).toDouble(),
    narrative: (json['narrative'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toList(growable: false),
    about: (json['about'] as List<dynamic>? ?? const []).cast<String>().toList(
      growable: false,
    ),
    accent: switch (json['accent']) {
      final String hex => int.parse(hex.replaceFirst('#', '0xFF')),
      _ => 0xFFFFD400,
    },
  );
}
