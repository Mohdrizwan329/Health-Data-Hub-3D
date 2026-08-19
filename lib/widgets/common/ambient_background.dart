import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../painters/ambient_glow_painter.dart';

/// The three background washes the design uses.
enum AmbientTint {
  /// Genotype, and the whole-body health overview.
  green,

  /// Blood and hormone sections of the phenotype half.
  blue,

  /// Organ condition screens.
  crimson,

  /// Standalone marker detail screens.
  amber,
}

/// Full-bleed backdrop that tints the page for the active [AmbientTint].
///
/// The glow layout is fixed per tint, so the spot lists are `const` and the
/// painter short-circuits repaints while the user scrolls.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.tint, required this.child});

  final AmbientTint tint;
  final Widget child;

  static const _green = [
    GlowSpot(
      alignment: Alignment(0, -1.05),
      color: AppColors.genotypeGlow,
      radius: 0.30,
      intensity: 0.85,
    ),
    GlowSpot(
      alignment: Alignment(-1.1, 0.62),
      color: AppColors.genotypeHalo,
      radius: 0.22,
      intensity: 0.16,
    ),
    GlowSpot(
      alignment: Alignment(1.08, 0.15),
      color: AppColors.genotypeGlow,
      radius: 0.20,
      intensity: 0.16,
    ),
  ];

  static const _blue = [
    GlowSpot(
      alignment: Alignment(0, -0.95),
      color: AppColors.phenotypeGlow,
      radius: 0.34,
      intensity: 0.9,
    ),
    GlowSpot(
      alignment: Alignment(-0.9, -0.3),
      color: AppColors.phenotypeHalo,
      radius: 0.24,
      intensity: 0.22,
    ),
    GlowSpot(
      alignment: Alignment(0.95, 0.55),
      color: AppColors.phenotypeHalo,
      radius: 0.22,
      intensity: 0.16,
    ),
  ];

  static const _crimson = [
    GlowSpot(
      alignment: Alignment(0, -0.72),
      color: AppColors.conditionGlow,
      radius: 0.40,
      intensity: 0.95,
    ),
    GlowSpot(
      alignment: Alignment(-1.05, 0.12),
      color: AppColors.conditionHalo,
      radius: 0.24,
      intensity: 0.20,
    ),
    GlowSpot(
      alignment: Alignment(1.05, 0.72),
      color: AppColors.conditionGlow,
      radius: 0.26,
      intensity: 0.22,
    ),
  ];

  static const _amber = [
    GlowSpot(
      alignment: Alignment(0, -1.0),
      color: AppColors.markerGlow,
      radius: 0.42,
      intensity: 1.0,
    ),
    GlowSpot(
      alignment: Alignment(-0.9, 0.35),
      color: AppColors.markerHalo,
      radius: 0.22,
      intensity: 0.14,
    ),
  ];

  Color get _base => switch (tint) {
    AmbientTint.green => AppColors.genotypeBase,
    AmbientTint.blue => AppColors.phenotypeBase,
    AmbientTint.crimson => AppColors.conditionBase,
    AmbientTint.amber => AppColors.markerBase,
  };

  List<GlowSpot> get _spots => switch (tint) {
    AmbientTint.green => _green,
    AmbientTint.blue => _blue,
    AmbientTint.crimson => _crimson,
    AmbientTint.amber => _amber,
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: _base),
      child: Stack(
        children: [
          Positioned.fill(
            // Cross-fading two painters keeps the tint change smooth without
            // rebuilding the page content underneath.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              child: RepaintBoundary(
                key: ValueKey(tint),
                child: CustomPaint(
                  painter: AmbientGlowPainter(base: _base, spots: _spots),
                  // AnimatedSwitcher hands its children loose constraints, so
                  // the painter needs a child to take up the full box.
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
