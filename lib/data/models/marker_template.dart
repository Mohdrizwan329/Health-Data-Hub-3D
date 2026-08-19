import 'package:flutter/foundation.dart';

import 'impacted_parameter.dart';
import 'organ_detail.dart';

/// Blueprint for marker screens that the sample data does not spell out.
///
/// Every strength, weakness and risk row in the designs drills into the same
/// detail layout, so rather than duplicating that payload per marker the
/// template fills the gaps and only genuinely bespoke markers (e.g. `Mentzer`)
/// are written out in full.
@immutable
class MarkerTemplate {
  const MarkerTemplate({
    required this.unit,
    required this.tint,
    required this.statusLabel,
    required this.markerLabel,
    required this.impactedBy,
    required this.bands,
    required this.impactedParameters,
    required this.about,
  });

  final String unit;
  final String tint;
  final String statusLabel;
  final String markerLabel;

  /// May contain the `{marker}` placeholder, like the copy fields.
  final String impactedBy;
  final List<GaugeBand> bands;
  final List<ImpactedParameter> impactedParameters;
  final List<String> about;

  static const _placeholder = '{marker}';

  /// Builds the detail screen payload for [name], carrying [score] over from
  /// the tile or risk row the user tapped so the gauge reads the same value.
  OrganDetail build(String name, {double? score, String? valueLabel}) {
    String fill(String source) => source.replaceAll(_placeholder, name);
    final value = score ?? 0;
    return OrganDetail(
      id: name.toLowerCase().replaceAll(' ', '_'),
      organ: name,
      unit: unit,
      tint: tint,
      score: value,
      statusLabel: statusLabel,
      markerLabel: markerLabel,
      markerValue: valueLabel ?? OrganDetail.formatReading(value),
      impactedBy: fill(impactedBy),
      bands: bands,
      impactedParameters: [
        for (final p in impactedParameters)
          ImpactedParameter(title: p.title, description: fill(p.description)),
      ],
      about: [for (final paragraph in about) fill(paragraph)],
    );
  }

  factory MarkerTemplate.fromJson(Map<String, dynamic> json) => MarkerTemplate(
    unit: json['unit'] as String? ?? '%',
    tint: json['tint'] as String? ?? 'amber',
    statusLabel: json['status_label'] as String? ?? '',
    markerLabel: json['marker_label'] as String? ?? '',
    impactedBy: json['impacted_by'] as String? ?? _placeholder,
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
