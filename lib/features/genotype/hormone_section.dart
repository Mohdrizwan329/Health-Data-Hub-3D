import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/widgets.dart';
import 'marker_slots.dart';

/// Hormone stage, gauge, ranges and narrative.
///
/// Mirrors the gene section's rhythm, with the RANGES legend sitting between
/// the gauge and the narrative as the design specifies.
class HormoneSection extends ConsumerWidget {
  const HormoneSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(hubDataProvider).valueOrNull;
    final hormone = ref.watch(selectedHormoneProvider);
    if (data == null || hormone == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final hormones = data.genotype.hormones;
    return SliverList.list(
      children: [
        const SizedBox(height: 8),
        ScoreStage(
          artAsset: 'assets/images/dna_helix.png',
          markers: [
            for (final (i, item) in hormones.indexed)
              StageMarker(
                alignment: MarkerSlots.at(MarkerSlots.hormones, i).alignment,
                child: MarkerChip(
                  title: item.name,
                  selected: item.id == hormone.id,
                  accent: Color(item.accent),
                  scale: MarkerSlots.at(MarkerSlots.hormones, i).scale,
                  onTap: () =>
                      ref.read(selectedHormoneIdProvider.notifier).state =
                          item.id,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${hormone.name} Score',
          textAlign: TextAlign.center,
          style: AppTypography.gaugeCaption,
        ),
        const SizedBox(height: 18),
        Center(
          child: ScoreGauge(
            value: hormone.score,
            accent: Color(hormone.accent),
            centerLabel: hormone.scoreLabel,
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: AppTheme.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RANGES', style: AppTypography.sectionTitle),
              const SizedBox(height: 18),
              RangesLegend(bands: data.genotype.ranges),
              const SizedBox(height: 30),
              NarrativeCard(
                title: hormone.name,
                subtitle: hormone.subtitle,
                scoreLabel: 'Genotype Score:',
                scoreValue: hormone.scoreLabel,
                accent: Color(hormone.accent),
                paragraphs: hormone.narrative,
              ),
              const SizedBox(height: 30),
              AboutSection(
                title: 'ABOUT ${hormone.name}',
                emphasis: '(${hormone.subtitle})',
                paragraphs: hormone.about,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
