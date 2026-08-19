import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Where markers sit around the stage artwork, and how large each renders.
///
/// Positions are fixed slots rather than per-marker data so that adding a gene
/// to the JSON never requires touching layout code.
@immutable
class MarkerSlot {
  const MarkerSlot(this.alignment, this.scale);

  final Alignment alignment;
  final double scale;
}

abstract final class MarkerSlots {
  /// Ring used by the gene stage — mirrors the design's depth arrangement.
  static const genes = <MarkerSlot>[
    MarkerSlot(Alignment(-0.94, -0.10), 1.00),
    MarkerSlot(Alignment(0.96, -0.52), 0.96),
    MarkerSlot(Alignment(-0.30, 0.44), 0.58),
    MarkerSlot(Alignment(0.96, 0.30), 0.72),
    MarkerSlot(Alignment(-0.92, 0.66), 0.64),
    MarkerSlot(Alignment(0.34, -0.96), 0.66),
  ];

  /// Four corners around the helix for the hormone stage.
  static const hormones = <MarkerSlot>[
    MarkerSlot(Alignment(-0.94, -0.72), 1.00),
    MarkerSlot(Alignment(-0.92, -0.14), 1.00),
    MarkerSlot(Alignment(0.94, -0.80), 0.96),
    MarkerSlot(Alignment(0.96, -0.20), 1.00),
  ];

  /// Wraps around when there are more markers than slots.
  static MarkerSlot at(List<MarkerSlot> slots, int index) =>
      slots[index % slots.length];
}
