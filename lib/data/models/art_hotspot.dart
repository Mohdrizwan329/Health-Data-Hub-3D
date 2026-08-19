import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// What a hotspot opens when it is tapped.
enum HotspotKind { condition, marker }

/// A parsed `condition:heart` / `marker:Mentzer` link from the sample data.
@immutable
class HotspotTarget {
  const HotspotTarget({required this.kind, required this.value});

  final HotspotKind kind;

  /// Condition id, or marker name.
  final String value;

  factory HotspotTarget.parse(String raw) {
    final i = raw.indexOf(':');
    final kind = i < 0 ? '' : raw.substring(0, i);
    return HotspotTarget(
      kind: kind == 'condition' ? HotspotKind.condition : HotspotKind.marker,
      value: i < 0 ? raw : raw.substring(i + 1),
    );
  }
}

/// A tap target pinned over hero artwork.
///
/// The designs bake their annotation boxes into the artwork, so selection is
/// expressed as invisible regions measured against the image rather than as
/// widgets that would redraw the callouts.
@immutable
class ArtHotspot {
  const ArtHotspot({
    required this.label,
    required this.target,
    required this.alignment,
    required this.widthFactor,
    required this.heightFactor,
    this.pulse = false,
  });

  /// Spoken by screen readers, since the artwork carries the visible text.
  final String label;
  final HotspotTarget target;

  /// Centre of the region, in the artwork's own alignment space.
  final Alignment alignment;

  /// Region size as a fraction of the artwork.
  final double widthFactor;
  final double heightFactor;

  /// Whether the region breathes a soft halo to advertise that it is tappable.
  final bool pulse;

  factory ArtHotspot.fromJson(Map<String, dynamic> json) => ArtHotspot(
    label: json['label'] as String? ?? '',
    target: HotspotTarget.parse(json['target'] as String? ?? ''),
    alignment: Alignment(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    ),
    widthFactor: (json['width'] as num?)?.toDouble() ?? 0.2,
    heightFactor: (json['height'] as num?)?.toDouble() ?? 0.1,
    pulse: json['pulse'] as bool? ?? false,
  );

  static List<ArtHotspot> listFrom(dynamic json) =>
      (json as List<dynamic>? ?? const [])
          .map((e) => ArtHotspot.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
}
