import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';
import '../../widgets/widgets.dart';
import 'hormone_section.dart';
import 'marker_slots.dart';

/// The genotype half of the hub.
///
/// Shows the gene stage by default and swaps to the hormone stage when the user
/// picks that section from the disclosure panel.
class GenotypeView extends ConsumerStatefulWidget {
  const GenotypeView({super.key});

  @override
  ConsumerState<GenotypeView> createState() => _GenotypeViewState();
}

class _GenotypeViewState extends ConsumerState<GenotypeView> {
  bool _sectionsOpen = false;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(hubDataProvider).valueOrNull;
    final gene = ref.watch(selectedGeneProvider);
    if (data == null || gene == null) return const SizedBox.shrink();

    final section = ref.watch(genotypeSectionProvider);
    final showHormones = section == 'hormone';

    return CustomScrollView(
      // Physics chosen for a consistent feel across platforms.
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: AppTheme.screenPadding,
          sliver: SliverList.list(
            children: [
              SectionHeading(
                title: showHormones
                    ? 'Hormone Regulation Score'
                    : 'Gene-to-Health Overview',
                expanded: _sectionsOpen,
                onToggle: () => setState(() => _sectionsOpen = !_sectionsOpen),
              ),
              const SizedBox(height: 14),
              _SectionPanel(
                open: _sectionsOpen,
                sections: data.genotype.sections,
                selectedId: section,
                onSelect: (id) {
                  ref.read(genotypeSectionProvider.notifier).state = id;
                  setState(() => _sectionsOpen = false);
                },
              ),
            ],
          ),
        ),
        if (showHormones)
          const HormoneSection()
        else
          _GeneSection(data: data, gene: gene),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}

/// Collapsible list of genotype sections.
class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
    required this.open,
    required this.sections,
    required this.selectedId,
    required this.onSelect,
  });

  final bool open;
  final List<HubSection> sections;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !open
          ? const SizedBox(width: double.infinity)
          : GradientBorderCard(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  for (final (i, section) in sections.indexed) ...[
                    if (i > 0) const SizedBox(height: 10),
                    HubSectionCard(
                      title: section.title,
                      subtitle: section.subtitle,
                      icon: section.icon,
                      selected: section.id == selectedId,
                      onTap: () => onSelect(section.id),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

/// Stage, gauge, narrative and organwise grids for the selected gene.
class _GeneSection extends ConsumerWidget {
  const _GeneSection({required this.data, required this.gene});

  final HubData data;
  final GeneMarker gene;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genes = data.genotype.genes;
    return SliverList.list(
      children: [
        const SizedBox(height: 8),
        ScoreStage(
          artAsset: 'assets/images/dna_helix.png',
          markers: [
            for (final (i, item) in genes.indexed)
              StageMarker(
                alignment: MarkerSlots.at(MarkerSlots.genes, i).alignment,
                child: MarkerChip(
                  title: item.symbol,
                  subtitle: '(${item.fullName})',
                  selected: item.id == gene.id,
                  accent: Color(item.accent),
                  scale: MarkerSlots.at(MarkerSlots.genes, i).scale,
                  onTap: () =>
                      ref.read(selectedGeneIdProvider.notifier).state = item.id,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${gene.symbol}\nGenotype Score',
          textAlign: TextAlign.center,
          style: AppTypography.gaugeCaption,
        ),
        const SizedBox(height: 18),
        Center(
          child: ScoreGauge(
            value: gene.score,
            accent: Color(gene.accent),
            centerLabel: gene.scoreLabel,
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: AppTheme.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NarrativeCard(
                title: gene.symbol,
                subtitle: gene.fullName,
                scoreLabel: 'Genotype Score:',
                scoreValue: gene.scoreLabel,
                accent: Color(gene.accent),
                paragraphs: gene.narrative,
              ),
              const SizedBox(height: 30),
              AboutSection(
                title: 'ABOUT ${gene.symbol}',
                emphasis: gene.fullName,
                paragraphs: gene.about,
              ),
              const SizedBox(height: 28),
              Text(
                '${gene.symbol} Organwise Score',
                style: AppTypography.sectionTitle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 20),
              _OrganwiseGroup(
                caption: 'Strengths :',
                color: AppColors.optimalBright,
                scores: gene.strengths,
                isStrength: true,
                gene: gene,
                data: data,
              ),
              const SizedBox(height: 24),
              _OrganwiseGroup(
                caption: 'Weakness :',
                color: AppColors.low,
                scores: gene.weaknesses,
                isStrength: false,
                gene: gene,
                data: data,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrganwiseGroup extends StatelessWidget {
  const _OrganwiseGroup({
    required this.caption,
    required this.color,
    required this.scores,
    required this.isStrength,
    required this.gene,
    required this.data,
  });

  final String caption;
  final Color color;
  final List<OrganScore> scores;
  final bool isStrength;
  final GeneMarker gene;
  final HubData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          style: AppTypography.cardTitle.copyWith(fontSize: 19, color: color),
        ),
        const SizedBox(height: 12),
        OrganScoreGrid(
          scores: scores,
          isStrength: isStrength,
          // Genes spell out only a few organ breakdowns; the rest fall back to
          // the generic marker screen so no tile is a dead end.
          onTap: (score) => context.openMarker(
            data,
            score.label,
            score: score.percent,
            gene: gene,
          ),
        ),
      ],
    );
  }
}
