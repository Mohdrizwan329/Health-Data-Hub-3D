import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import '../data/repositories/hub_repository.dart';
import '../widgets/common/ambient_background.dart';

/// Which half of the hub the user is looking at.
enum HubMode { genotype, phenotype }

final hubRepositoryProvider = Provider<HubRepository>((ref) => HubRepository());

/// The bundled snapshot, loaded once and shared by every screen.
final hubDataProvider = FutureProvider<HubData>(
  (ref) => ref.watch(hubRepositoryProvider).fetch(),
);

/// Genotype / Phenotype segmented control.
final hubModeProvider = StateProvider<HubMode>((ref) => HubMode.genotype);

/// Gene currently driving the genotype screen.
final selectedGeneIdProvider = StateProvider<String>((ref) => 'slc6a4');

/// Hormone currently driving the hormone screen.
final selectedHormoneIdProvider = StateProvider<String>((ref) => 'dopamine');

/// Which genotype section is active — genes vs. hormones.
final genotypeSectionProvider = StateProvider<String>((ref) => 'wellness');

/// Which phenotype section is active — organ, blood or hormone.
final phenotypeSectionProvider = StateProvider<String>((ref) => 'blood');

/// Background wash for the current mode and section.
///
/// The organ section of the phenotype half is drawn on green, matching the
/// design; the blood and hormone sections stay blue.
final ambientTintProvider = Provider<AmbientTint>((ref) {
  if (ref.watch(hubModeProvider) == HubMode.genotype) return AmbientTint.green;
  return ref.watch(phenotypeSectionProvider) == 'organ'
      ? AmbientTint.green
      : AmbientTint.blue;
});

/// Resolved gene for the current selection.
final selectedGeneProvider = Provider<GeneMarker?>((ref) {
  final data = ref.watch(hubDataProvider).valueOrNull;
  if (data == null) return null;
  return data.genotype.geneById(ref.watch(selectedGeneIdProvider));
});

/// Resolved hormone for the current selection.
final selectedHormoneProvider = Provider<HormoneMarker?>((ref) {
  final data = ref.watch(hubDataProvider).valueOrNull;
  if (data == null) return null;
  return data.genotype.hormoneById(ref.watch(selectedHormoneIdProvider));
});
