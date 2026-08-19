import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/providers.dart';
import '../../data/models/models.dart';
import '../../widgets/painters/arc_glow_painter.dart';
import '../../widgets/widgets.dart';

/// A single organ's condition overview — hero artwork with its annotations,
/// the condition dial, guidance, strengths / weaknesses and risk assessment.
///
/// One screen serves every organ; only the data differs.
class OrganConditionScreen extends ConsumerWidget {
  const OrganConditionScreen({super.key, required this.condition});

  final OrganCondition condition;

  static Route<void> route(OrganCondition condition) => PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, _, _) => OrganConditionScreen(condition: condition),
    transitionsBuilder: (_, animation, _, child) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(hubDataProvider).valueOrNull;
    return Scaffold(
      body: AmbientBackground(
        tint: AmbientTint.crimson,
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: AppTheme.screenPadding,
                sliver: SliverList.list(
                  children: [
                    HubHeader(
                      title: 'Phenotype',
                      trailing: GlyphButton(
                        asset: 'assets/icons/icon_molecule.png',
                        // Same glyph as the hub header: it returns to the hub,
                        // rather than sitting there inert on a pushed screen.
                        onTap: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        condition.title,
                        textAlign: TextAlign.center,
                        style: AppTypography.sectionTitle.copyWith(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverList.list(
                children: [
                  const SizedBox(height: 10),
                  _Hero(
                    condition: condition,
                    onHotspot: data == null
                        ? null
                        : (hotspot) => context.openHotspot(data, hotspot),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: AppTheme.screenPadding,
                    child: Text(
                      condition.conditionTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.sectionTitle.copyWith(
                        fontSize: 16.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: ScoreGauge(
                      value: condition.score,
                      accent: AppColors.conditionBar,
                      centerLabel: condition.scoreLabel,
                      size: 300,
                      ringAccent: AppColors.conditionRing,
                      tickColor: AppColors.conditionRing.withValues(
                        alpha: 0.55,
                      ),
                      innerGlow: AppColors.conditionGlow.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),
                  // Bowed glow closing off the dial.
                  SizedBox(
                    height: 34,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: const ArcGlowPainter(
                          color: AppColors.conditionBar,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: AppTheme.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RecommendationCard(
                          title: condition.recommendationTitle,
                          items: condition.recommendations,
                          numbered: condition.numbered,
                        ),
                        if (condition.strengths.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          _Group(
                            caption: 'Strengths :',
                            scores: condition.strengths,
                            isStrength: true,
                            onTap: data == null
                                ? null
                                : (score) => context.openMarker(
                                    data,
                                    score.label,
                                    score: score.percent,
                                  ),
                          ),
                        ],
                        if (condition.weaknesses.isNotEmpty) ...[
                          const SizedBox(height: 26),
                          _Group(
                            caption: 'Weakness :',
                            scores: condition.weaknesses,
                            isStrength: false,
                            onTap: data == null
                                ? null
                                : (score) => context.openMarker(
                                    data,
                                    score.label,
                                    score: score.percent,
                                  ),
                          ),
                        ],
                        const SizedBox(height: 30),
                        Center(
                          child: Text(
                            condition.riskTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.sectionTitle.copyWith(
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        RiskAssessmentList(
                          markers: condition.risks,
                          onTap: data == null
                              ? null
                              : (marker) => context.openMarker(
                                  data,
                                  marker.name,
                                  score: double.tryParse(marker.value),
                                  valueLabel: marker.value,
                                ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero artwork sitting on the lit platform.
///
/// The design's annotation boxes are part of the artwork, so the "View in
/// Details" links are invisible regions measured against the image.
class _Hero extends StatelessWidget {
  const _Hero({required this.condition, this.onHotspot});

  final OrganCondition condition;
  final ValueChanged<ArtHotspot>? onHotspot;

  @override
  Widget build(BuildContext context) {
    return ScoreStage(
      artAsset: condition.heroAsset,
      artWidthFactor: 0.98,
      artAlignment: const Alignment(0, -0.46),
      platformWidthFactor: 0.60,
      platformAlignment: const Alignment(0, 0.86),
      aspectRatio: 0.84,
      markers: const [],
      hotspots: condition.hotspots,
      onHotspot: onHotspot,
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.caption,
    required this.scores,
    required this.isStrength,
    this.onTap,
  });

  final String caption;
  final List<OrganScore> scores;
  final bool isStrength;
  final ValueChanged<OrganScore>? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: AppTypography.sectionTitle.copyWith(fontSize: 19)),
        const SizedBox(height: 12),
        OrganScoreGrid(
          scores: scores,
          isStrength: isStrength,
          showPercent: false,
          onTap: onTap,
        ),
      ],
    );
  }
}
