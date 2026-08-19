import 'package:flutter/widgets.dart';

import '../data/models/models.dart';
import '../features/conditions/organ_condition_screen.dart';
import '../features/gene_detail/organ_detail_screen.dart';

/// Every drill-down in the hub, in one place.
///
/// Screens describe *what* the user picked; this decides which route that
/// opens, so the tile, risk row and artwork hotspot all land on the same
/// destination without repeating route wiring.
extension HubNavigation on BuildContext {
  void openCondition(OrganCondition condition) =>
      Navigator.of(this).push(OrganConditionScreen.route(condition));

  void openDetail(OrganDetail detail, {GeneMarker? gene}) =>
      Navigator.of(this).push(OrganDetailScreen.route(gene: gene, detail: detail));

  /// Opens the score behind a strength / weakness tile or a risk row, falling
  /// back to the generic marker screen when the sample data has no bespoke one.
  void openMarker(
    HubData data,
    String name, {
    double? score,
    String? valueLabel,
    GeneMarker? gene,
  }) => openDetail(
    gene?.detailFor(name) ??
        data.detailFor(name, score: score, valueLabel: valueLabel),
    gene: gene,
  );

  /// Follows an artwork hotspot to whichever screen it points at.
  void openHotspot(HubData data, ArtHotspot hotspot) {
    switch (data.targetOf(hotspot.target)) {
      case final OrganCondition condition:
        openCondition(condition);
      case final OrganDetail detail:
        openDetail(detail);
      default:
        break;
    }
  }
}
