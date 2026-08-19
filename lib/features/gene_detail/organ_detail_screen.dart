import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';
import '../../widgets/widgets.dart';

/// Per-organ breakdown of a gene score, e.g. "SLC6A4 Heart Score".
///
/// Reached by tapping a tile in the organwise grid.
class OrganDetailScreen extends StatelessWidget {
  const OrganDetailScreen({super.key, this.gene, required this.detail});

  /// Absent for standalone marker screens such as `Mentzer`.
  final GeneMarker? gene;
  final OrganDetail detail;

  /// Slide-up route, matching the drill-down feel of the design.
  static Route<void> route({GeneMarker? gene, required OrganDetail detail}) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, _, _) => OrganDetailScreen(gene: gene, detail: detail),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.06), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        ),
      ),
    );
  }

  String get _title =>
      detail.title ??
      (gene == null ? detail.organ : '${gene!.symbol} ${detail.organ} Score');

  AmbientTint get _tint => switch (detail.tint) {
    'crimson' => AmbientTint.crimson,
    'blue' => AmbientTint.blue,
    'amber' => AmbientTint.amber,
    _ => AmbientTint.green,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        tint: _tint,
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
                    _Header(title: _title, centred: gene == null),
                    const SizedBox(height: 18),
                    _ScoreHeadline(detail: detail),
                    const SizedBox(height: 20),
                    NeedleGauge(
                      // The needle sits proportionally across the whole arc.
                      fraction: (detail.score / 100).clamp(0.0, 1.0),
                      segmentColors: [
                        for (final band in detail.bands) Color(band.color),
                      ],
                      segmentLabels: [
                        for (final band in detail.bands) band.label,
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(child: _MarkerPill(detail: detail)),
                    const SizedBox(height: 34),
                    Text('RANGES', style: AppTypography.sectionTitle),
                    const SizedBox(height: 20),
                    _BandLegend(bands: detail.bands),
                    const SizedBox(height: 30),
                    Text(
                      'Parameters that are generally impacted by '
                      '${detail.impactedBy}:',
                      style: AppTypography.cardSubtitle.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    for (final parameter in detail.impactedParameters)
                      ExpandableParameterCard(parameter: parameter),
                    const SizedBox(height: 22),
                    AboutSection(
                      title: 'ABOUT $_title',
                      emphasis: '(${detail.scoreLabel} ${detail.unit})',
                      paragraphs: detail.about,
                    ),
                    const SizedBox(height: 56),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.centred = false});

  final String title;

  /// The standalone marker screen centres its title, as in the design.
  final bool centred;

  @override
  Widget build(BuildContext context) {
    if (centred) {
      return SizedBox(
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, size: 26),
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: AppTypography.sectionTitle.copyWith(fontSize: 24),
            ),
          ],
        ),
      );
    }
    return Row(
      children: [
        InkResponse(
          onTap: () => Navigator.of(context).maybePop(),
          radius: 28,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
            ),
            child: const Icon(Icons.chevron_left, size: 30),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTypography.sectionTitle.copyWith(fontSize: 25),
          ),
        ),
      ],
    );
  }
}

class _ScoreHeadline extends StatelessWidget {
  const _ScoreHeadline({required this.detail});

  final OrganDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              detail.scoreLabel,
              style: AppTypography.sectionTitle.copyWith(fontSize: 42),
            ),
            const SizedBox(width: 8),
            Text(
              detail.unit,
              style: AppTypography.metricUnit.copyWith(fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          detail.statusLabel,
          style: AppTypography.body.copyWith(
            fontSize: 22,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

/// Outlined amber pill sitting under the dial.
class _MarkerPill extends StatelessWidget {
  const _MarkerPill({required this.detail});

  final OrganDetail detail;

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFFB300);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        border: Border.all(color: amber, width: 1.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            detail.markerLabel,
            style: AppTypography.cardTitle.copyWith(color: amber),
          ),
          const SizedBox(width: 8),
          Text(
            detail.markerValue,
            style: AppTypography.metricValue.copyWith(
              fontSize: 22,
              color: amber,
            ),
          ),
        ],
      ),
    );
  }
}

/// Two-column legend of the dial's bands.
class _BandLegend extends StatelessWidget {
  const _BandLegend({required this.bands});

  final List<GaugeBand> bands;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        final twoUp = constraints.maxWidth >= 330;
        final width = twoUp
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: gap,
          runSpacing: 16,
          children: [
            for (final band in bands)
              SizedBox(
                width: width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(band.color),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: Color(band.color).withValues(alpha: 0.55),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            band.rangeText,
                            style: AppTypography.body.copyWith(fontSize: 17),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            band.label.toUpperCase(),
                            style: AppTypography.bodyMuted.copyWith(
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
