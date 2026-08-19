import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';
import '../../widgets/painters/arc_glow_painter.dart';
import '../../widgets/widgets.dart';

/// Whole-body Health Conditions Overview.
///
/// Sits inside the phenotype scroll view, so it contributes slivers rather than
/// its own scaffold.
class HealthConditionsView extends ConsumerStatefulWidget {
  const HealthConditionsView({super.key, required this.health});

  final HealthConditions health;

  @override
  ConsumerState<HealthConditionsView> createState() =>
      _HealthConditionsViewState();
}

class _HealthConditionsViewState extends ConsumerState<HealthConditionsView> {
  int _hormone = 0;

  @override
  Widget build(BuildContext context) {
    final health = widget.health;
    final data = ref.watch(hubDataProvider).valueOrNull;
    return SliverList.list(
      children: [
        const SizedBox(height: 6),
        // The body stands on the same lit platform as the other stages.
        ScoreStage(
          artAsset: health.bodyAsset,
          artWidthFactor: 0.96,
          artAlignment: const Alignment(0, -0.52),
          platformWidthFactor: 0.66,
          platformAlignment: const Alignment(0, 0.94),
          aspectRatio: 0.80,
          markers: const [],
          // The figure's callouts are painted into the asset, so organ
          // selection rides on invisible regions pinned over them.
          hotspots: health.hotspots,
          onHotspot: data == null
              ? null
              : (hotspot) => context.openHotspot(data, hotspot),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: AppTheme.screenPadding,
          child: SegmentedToggle(
            labels: health.toggle,
            selectedIndex: _hormone,
            onChanged: (i) => setState(() => _hormone = i),
            thumbColor: AppColors.optimal,
            height: 50,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: AppTheme.screenPadding,
          child: ActivityChart(
            // Keyed so switching hormone replays the draw-in.
            key: ValueKey(health.seriesAt(_hormone).id),
            series: health.seriesAt(_hormone),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: AppTheme.screenPadding,
          child: _SummaryRow(summary: health.summary),
        ),
        const SizedBox(height: 30),
        Text(
          health.immuneTitle,
          textAlign: TextAlign.center,
          style: AppTypography.sectionTitle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 14),
        Center(
          child: ScoreGauge(
            value: health.immuneScore,
            accent: AppColors.conditionBar,
            centerLabel: '${health.immuneScore.round()}%',
            size: 300,
            ringAccent: AppColors.conditionRing,
            tickColor: AppColors.conditionRing.withValues(alpha: 0.55),
            innerGlow: AppColors.conditionGlow.withValues(alpha: 0.85),
          ),
        ),
        SizedBox(
          height: 34,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: const ArcGlowPainter(color: AppColors.conditionRing),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: AppTheme.screenPadding,
          child: RecommendationCard(
            title: health.guidanceTitle,
            intro: health.guidanceIntro,
            items: health.guidanceItems,
            numbered: false,
            borderColor: AppColors.accentCyan.withValues(alpha: 0.7),
            gradient: const [
              Color(0xFF08243B),
              Color(0xFF071A2C),
              Color(0xFF03070D),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Padding(
          padding: AppTheme.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Strengths :',
                style: AppTypography.sectionTitle.copyWith(fontSize: 19),
              ),
              const SizedBox(height: 12),
              OrganScoreGrid(
                scores: health.strengths,
                isStrength: true,
                showPercent: false,
                onTap: data == null
                    ? null
                    : (score) => context.openMarker(
                        data,
                        score.label,
                        score: score.percent,
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                'Weakness :',
                style: AppTypography.sectionTitle.copyWith(fontSize: 19),
              ),
              const SizedBox(height: 12),
              OrganScoreGrid(
                scores: health.weaknesses,
                isStrength: false,
                showPercent: false,
                onTap: data == null
                    ? null
                    : (score) => context.openMarker(
                        data,
                        score.label,
                        score: score.percent,
                      ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }
}

/// Score card and its ABOUT copy, side by side when there is room.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final ScoreSummary summary;

  @override
  Widget build(BuildContext context) {
    final about = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary.aboutTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        for (final paragraph in summary.about)
          Text(paragraph, style: AppTypography.body.copyWith(fontSize: 14.5)),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final card = ScoreSummaryCard(
          summary: summary,
          artAsset: 'assets/images/dna_helix.png',
        );
        if (constraints.maxWidth < 340) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [card, const SizedBox(height: 16), about],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: constraints.maxWidth * 0.44, child: card),
            const SizedBox(width: 14),
            Expanded(child: about),
          ],
        );
      },
    );
  }
}
