import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'art_hotspot.dart';
import 'organ_score.dart';

/// One entry in the activity chart legend.
@immutable
class ActivityPhase {
  const ActivityPhase({required this.label, required this.color});

  final String label;
  final int color;

  factory ActivityPhase.fromJson(Map<String, dynamic> json) => ActivityPhase(
    label: json['label'] as String,
    color: int.parse((json['color'] as String).replaceFirst('#', '0xFF')),
  );
}

/// The plotted series behind the activity chart.
@immutable
class ActivitySeries {
  const ActivitySeries({
    required this.id,
    required this.title,
    required this.axisLabel,
    required this.points,
    required this.xTicks,
    required this.yTicks,
    required this.reference,
    required this.legend,
  });

  final String id;
  final String title;

  /// Caption rotated up the y axis.
  final String axisLabel;
  final List<Offset> points;
  final List<double> xTicks;
  final List<double> yTicks;
  final double reference;
  final List<ActivityPhase> legend;

  factory ActivitySeries.fromJson(Map<String, dynamic> json) => ActivitySeries(
    id: json['id'] as String,
    title: json['title'] as String,
    axisLabel: json['axis_label'] as String? ?? '',
    reference: (json['reference'] as num?)?.toDouble() ?? 0,
    points: (json['points'] as List<dynamic>? ?? const [])
        .map(
          (e) => Offset(
            ((e as List<dynamic>)[0] as num).toDouble(),
            (e[1] as num).toDouble(),
          ),
        )
        .toList(growable: false),
    xTicks: (json['x_ticks'] as List<dynamic>? ?? const [])
        .map((e) => (e as num).toDouble())
        .toList(growable: false),
    yTicks: (json['y_ticks'] as List<dynamic>? ?? const [])
        .map((e) => (e as num).toDouble())
        .toList(growable: false),
    legend: (json['legend'] as List<dynamic>? ?? const [])
        .map((e) => ActivityPhase.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );
}

/// The small "… Score" summary card beside the ABOUT copy.
@immutable
class ScoreSummary {
  const ScoreSummary({
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.caption,
    required this.aboutTitle,
    required this.about,
  });

  final String title;
  final String subtitle;
  final double percent;

  /// Small line under the reading, e.g. `Based on Hormone`.
  final String caption;
  final String aboutTitle;
  final List<String> about;

  factory ScoreSummary.fromJson(Map<String, dynamic> json) => ScoreSummary(
    title: json['title'] as String,
    subtitle: json['subtitle'] as String? ?? '',
    percent: (json['percent'] as num).toDouble(),
    caption: json['caption'] as String? ?? '',
    aboutTitle: json['about_title'] as String? ?? '',
    about: (json['about'] as List<dynamic>? ?? const []).cast<String>().toList(
      growable: false,
    ),
  );
}

/// Everything behind the Health Conditions Overview screen.
@immutable
class HealthConditions {
  const HealthConditions({
    required this.title,
    required this.bodyAsset,
    required this.hotspots,
    required this.toggle,
    required this.series,
    required this.summary,
    required this.immuneTitle,
    required this.immuneScore,
    required this.guidanceTitle,
    required this.guidanceIntro,
    required this.guidanceItems,
    required this.strengths,
    required this.weaknesses,
  });

  final String title;
  final String bodyAsset;

  /// Selectable regions pinned over the figure's baked-in annotations.
  final List<ArtHotspot> hotspots;

  /// Labels of the hormone switch under the figure.
  final List<String> toggle;

  /// One series per toggle option.
  final List<ActivitySeries> series;
  final ScoreSummary summary;

  final String immuneTitle;
  final double immuneScore;

  final String guidanceTitle;
  final List<String> guidanceIntro;
  final List<String> guidanceItems;
  final List<OrganScore> strengths;
  final List<OrganScore> weaknesses;

  ActivitySeries seriesAt(int index) =>
      series[index.clamp(0, series.length - 1)];

  factory HealthConditions.fromJson(Map<String, dynamic> json) =>
      HealthConditions(
        title: json['title'] as String,
        bodyAsset: json['body_asset'] as String,
        hotspots: ArtHotspot.listFrom(json['hotspots']),
        toggle: (json['toggle'] as List<dynamic>? ?? const [])
            .cast<String>()
            .toList(growable: false),
        series: (json['series'] as List<dynamic>? ?? const [])
            .map((e) => ActivitySeries.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        summary: ScoreSummary.fromJson(json['summary'] as Map<String, dynamic>),
        immuneTitle: json['immune_title'] as String? ?? '',
        immuneScore: (json['immune_score'] as num?)?.toDouble() ?? 0,
        guidanceTitle: json['guidance_title'] as String? ?? '',
        guidanceIntro: (json['guidance_intro'] as List<dynamic>? ?? const [])
            .cast<String>()
            .toList(growable: false),
        guidanceItems: (json['guidance_items'] as List<dynamic>? ?? const [])
            .cast<String>()
            .toList(growable: false),
        strengths: (json['strengths'] as List<dynamic>? ?? const [])
            .map((e) => OrganScore.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        weaknesses: (json['weaknesses'] as List<dynamic>? ?? const [])
            .map((e) => OrganScore.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );
}
