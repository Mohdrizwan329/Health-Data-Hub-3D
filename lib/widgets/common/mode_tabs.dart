import 'package:flutter/material.dart';

import '../../app/providers.dart';
import 'segmented_toggle.dart';

/// The Genotype / Phenotype segmented control.
class ModeTabs extends StatelessWidget {
  const ModeTabs({super.key, required this.mode, required this.onChanged});

  final HubMode mode;
  final ValueChanged<HubMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedToggle(
      labels: const ['Genotype', 'Phenotype'],
      selectedIndex: mode == HubMode.genotype ? 0 : 1,
      onChanged: (i) =>
          onChanged(i == 0 ? HubMode.genotype : HubMode.phenotype),
    );
  }
}
