import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';
import '../../widgets/widgets.dart';
import '../conditions/health_conditions_view.dart';

/// The phenotype half: measured blood readings rather than inherited scores.
class PhenotypeView extends ConsumerStatefulWidget {
  const PhenotypeView({super.key});

  @override
  ConsumerState<PhenotypeView> createState() => _PhenotypeViewState();
}

class _PhenotypeViewState extends ConsumerState<PhenotypeView> {
  bool _sectionsOpen = false;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(hubDataProvider).valueOrNull;
    if (data == null) return const SizedBox.shrink();
    final pheno = data.phenotype;
    final sectionId = ref.watch(phenotypeSectionProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: AppTheme.screenPadding,
          sliver: SliverList.list(
            children: [
              SectionHeading(
                title: sectionId == 'organ'
                    ? data.health.title
                    : _sectionTitle(pheno.sections, sectionId),
                expanded: _sectionsOpen,
                onToggle: () => setState(() => _sectionsOpen = !_sectionsOpen),
              ),
              const SizedBox(height: 14),
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: !_sectionsOpen
                    ? const SizedBox(width: double.infinity)
                    : GradientBorderCard(
                        padding: const EdgeInsets.all(10),
                        colors: const [Color(0xFF23C4E8), Color(0xFF1B6FA8)],
                        child: Column(
                          children: [
                            for (final (i, section)
                                in pheno.sections.indexed) ...[
                              if (i > 0) const SizedBox(height: 10),
                              HubSectionCard(
                                title: section.title,
                                subtitle: section.subtitle,
                                icon: section.icon,
                                selected: section.id == sectionId,
                                onTap: () {
                                  ref
                                      .read(phenotypeSectionProvider.notifier)
                                      .state = section
                                      .id;
                                  // Organ Metrics keeps the panel open so the
                                  // organ list stays reachable, as in the
                                  // design's drawer.
                                  setState(
                                    () => _sectionsOpen = section.id == 'organ',
                                  );
                                },
                              ),
                            ],
                            if (sectionId == 'organ') ...[
                              const SizedBox(height: 14),
                              _OrganRows(conditions: data.conditions),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        if (sectionId == 'organ')
          HealthConditionsView(health: data.health)
        else
          SliverList.list(
            children: [
              const SizedBox(height: 4),
              _BloodStage(chips: pheno.chips),
              const SizedBox(height: 22),
              Padding(
                padding: AppTheme.screenPadding,
                child: _TrendCards(cards: pheno.trendCards),
              ),
              const SizedBox(height: 34),
              Text(
                'Overall Blood Quality',
                textAlign: TextAlign.center,
                style: AppTypography.sectionTitle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 16),
              Center(
                child: ScoreGauge(
                  value: pheno.overallQuality,
                  maxValue: 100,
                  // The design renders this dial green regardless of which
                  // RANGES band the value falls in, so the colour is fixed here
                  // rather than derived from `pheno.band`.
                  accent: AppColors.optimal,
                  variant: ScoreGaugeVariant.quality,
                  size: 320,
                  tickLabels: const [
                    '0%',
                    '10%',
                    '20%',
                    '30%',
                    '40%',
                    '50%',
                    '60%',
                    '70%',
                    '80%',
                    '90%',
                    '100%',
                  ],
                ),
              ),
              const SizedBox(height: 34),
              Padding(
                padding: AppTheme.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RANGES', style: AppTypography.sectionTitle),
                    const SizedBox(height: 18),
                    RangesLegend(bands: data.genotype.ranges),
                    const SizedBox(height: 30),
                    BloodTable(
                      title: pheno.overviewTitle,
                      subtitle: pheno.overviewSubtitle,
                      metrics: pheno.metrics,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
      ],
    );
  }

  String _sectionTitle(List<HubSection> sections, String sectionId) {
    for (final section in sections) {
      if (section.id == sectionId) return section.title;
    }
    return 'Blood Metrics';
  }
}

/// Blood-cell artwork with the reading callouts pinned over it.
class _BloodStage extends StatelessWidget {
  const _BloodStage({required this.chips});

  final List<MetricChip> chips;

  @override
  Widget build(BuildContext context) {
    return ScoreStage(
      artAsset: 'assets/images/blood_cells.png',
      artWidthFactor: 0.92,
      artAlignment: const Alignment(0, -0.42),
      platformWidthFactor: 0.62,
      platformAlignment: const Alignment(0, 0.80),
      aspectRatio: 0.90,
      markers: [
        for (final (i, chip) in chips.indexed)
          StageMarker(
            alignment: chip.alignment,
            child: CalloutChip(
              title: chip.title,
              value: chip.value,
              unit: chip.unit,
              scale: chip.scale,
              // Dot points back toward the cells the chip refers to.
              anchor: i == 0
                  ? Alignment.centerRight
                  : i == 1
                  ? Alignment.bottomRight
                  : Alignment.centerLeft,
            ),
          ),
      ],
    );
  }
}

/// Side-by-side trend cards that stack when the viewport is narrow.
class _TrendCards extends StatelessWidget {
  const _TrendCards({required this.cards});

  final List<TrendCard> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              for (final (i, card) in cards.indexed) ...[
                if (i > 0) const SizedBox(height: gap),
                TrendMetricCard(card: card),
              ],
            ],
          );
        }
        // IntrinsicHeight lets both cards match the taller one; with only two
        // children the extra layout pass is negligible.
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, card) in cards.indexed) ...[
                if (i > 0) const SizedBox(width: gap),
                Expanded(child: TrendMetricCard(card: card)),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Organ rows inside the section panel, mirroring the design's drawer.
///
/// Picking one opens that organ's condition overview.
class _OrganRows extends StatelessWidget {
  const _OrganRows({required this.conditions});

  final List<OrganCondition> conditions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, condition) in conditions.indexed) ...[
          if (i > 0) const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.openCondition(condition),
              child: Ink(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: Image.asset(
                        condition.thumbAsset,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        condition.organ,
                        style: AppTypography.screenTitle.copyWith(fontSize: 20),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
