import 'package:flutter/material.dart';

/// Palette sampled directly from the Figma exports.
///
/// The hub renders in two visual modes — a green-tinted *genotype* world and a
/// blue-tinted *phenotype* world — so colours are grouped by that split, with a
/// shared set of semantic accents used by gauges, chips and range legends.
abstract final class AppColors {
  // ── Genotype (green) surfaces ───────────────────────────────────────────
  static const genotypeBase = Color(0xFF010600);
  static const genotypeGlow = Color(0xFF3D7A00);
  static const genotypeHalo = Color(0xFF6FCF17);

  // ── Phenotype (blue) surfaces ───────────────────────────────────────────
  static const phenotypeBase = Color(0xFF070A11);
  static const phenotypeGlow = Color(0xFF062C4F);
  static const phenotypeHalo = Color(0xFF1B6FA8);

  // ── Organ-condition (red) surfaces ──────────────────────────────────────
  static const conditionBase = Color(0xFF120302);
  static const conditionGlow = Color(0xFF7A1206);
  static const conditionHalo = Color(0xFFC8391C);

  /// Rim and value colour of the crimson condition dial.
  static const conditionRing = Color(0xFFFF6B5A);
  static const conditionBar = Color(0xFFFF8C1A);

  // ── Marker detail (amber) surfaces ──────────────────────────────────────
  static const markerBase = Color(0xFF0E0A02);
  static const markerGlow = Color(0xFF8A6510);
  static const markerHalo = Color(0xFFC9A227);

  // ── Risk assessment rows ────────────────────────────────────────────────
  static const riskAmber = Color(0xFFF5A524);
  static const riskGreen = Color(0xFF3DD146);
  static const riskRed = Color(0xFFE5484D);

  // ── Neutral surfaces ────────────────────────────────────────────────────
  static const surface = Color(0xFF1A1A1A);
  static const surfaceHigh = Color(0xFF262626);
  static const surfaceLow = Color(0xFF121212);
  static const tileSurface = Color(0xFF2B2B2B);
  static const divider = Color(0x33FFFFFF);

  // ── Text ────────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB4B7BC);
  static const textTertiary = Color(0xFF808387);

  // ── Semantic bands (gauges, chips, range legend) ────────────────────────
  static const optimal = Color(0xFF3DD146);
  static const optimalBright = Color(0xFF5DD400);
  static const optimalDeep = Color(0xFF257D0E);
  static const moderate = Color(0xFFFFD400);
  static const moderateDeep = Color(0xFFE0A800);
  static const low = Color(0xFFFF4B1F);
  static const lowSoft = Color(0xFFFF8A73);
  static const critical = Color(0xFFE23A2E);

  // ── Gauge internals ─────────────────────────────────────────────────────
  static const gaugeTrack = Color(0xFF0C0D15);
  static const gaugeTrackRing = Color(0xFF1C1E2B);
  static const gaugeTickDim = Color(0xFF3A3D4D);
  static const gaugeNeedle = Color(0xFFF2F2F2);

  // ── Accents used by cards, borders and chips ────────────────────────────
  static const accentCyan = Color(0xFF23C4E8);
  static const accentTeal = Color(0xFF17B8A6);
  static const accentViolet = Color(0xFF7A4BFF);
  static const accentAmber = Color(0xFFFFA726);

  /// Strength / weakness card fills used in the organwise grid.
  static const strengthFill = Color(0xFF032110);
  static const strengthBorder = Color(0xFF38AF0D);
  static const weaknessFill = Color(0xFF200B0B);
  static const weaknessBorder = Color(0xFF8C2A1E);
}
