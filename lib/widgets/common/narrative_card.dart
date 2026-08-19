import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// The lit card under a gauge carrying the marker's name, score and reading.
class NarrativeCard extends StatelessWidget {
  const NarrativeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.scoreLabel,
    required this.scoreValue,
    required this.paragraphs,
    required this.accent,
  });

  final String title;
  final String subtitle;

  /// Caption before the number, e.g. `Genotype Score:`.
  final String scoreLabel;
  final String scoreValue;
  final List<String> paragraphs;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.55)),
        gradient: const RadialGradient(
          center: Alignment(0, -0.4),
          radius: 1.1,
          colors: [Color(0xFF10344B), Color(0xFF05070C)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.body.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              '($subtitle)',
              style: AppTypography.body.copyWith(fontSize: 22),
            ),
          const SizedBox(height: 10),
          // Wrapped rather than a Row so a long caption drops the reading onto
          // the next line instead of overflowing on a narrow phone.
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                '$scoreLabel ',
                style: AppTypography.body.copyWith(fontSize: 17),
              ),
              Text(
                scoreValue,
                style: AppTypography.body.copyWith(
                  fontSize: 20,
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final paragraph in paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(paragraph, style: AppTypography.body),
            ),
        ],
      ),
    );
  }
}

/// "ABOUT …" heading with its accent underline and body copy.
class AboutSection extends StatelessWidget {
  const AboutSection({
    super.key,
    required this.title,
    required this.emphasis,
    required this.paragraphs,
  });

  final String title;

  /// Trailing part of the heading rendered smaller, as in the design.
  final String emphasis;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: title,
                style: AppTypography.body.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (emphasis.isNotEmpty)
                TextSpan(
                  text: ' $emphasis',
                  style: AppTypography.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2.5,
          width: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [AppColors.accentCyan, Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (final paragraph in paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(paragraph, style: AppTypography.body),
          ),
      ],
    );
  }
}
