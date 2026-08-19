import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';

/// The crimson guidance card on an organ condition screen.
///
/// Renders either a numbered list (the heart screen) or a bulleted one (the
/// lungs screen), driven by [numbered].
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.title,
    required this.items,
    this.numbered = true,
    this.intro = const [],
    this.gradient = const [
      Color(0xFF6B1108),
      Color(0xFF37080A),
      Color(0xFF0B0304),
    ],
    this.borderColor,
  });

  final String title;
  final List<String> items;
  final bool numbered;

  /// Paragraphs between the heading and the list.
  final List<String> intro;

  /// Card wash; the immune card uses a blue ramp instead of the crimson one.
  final List<Color> gradient;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.16),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
          stops: const [0, 0.55, 1],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.body.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          for (final paragraph in intro)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                paragraph,
                style: AppTypography.body.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ),
          const SizedBox(height: 18),
          for (final (i, item) in items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: numbered ? 24 : 16,
                    child: Text(
                      numbered ? '${i + 1}.' : '•',
                      style: AppTypography.body.copyWith(
                        fontSize: 14.5,
                        height: 1.6,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTypography.body.copyWith(
                        fontSize: 14.5,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
