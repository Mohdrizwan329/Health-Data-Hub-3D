import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../data/models/models.dart';

/// A "parameters generally impacted by …" row that expands to reveal its copy.
class ExpandableParameterCard extends StatefulWidget {
  const ExpandableParameterCard({
    super.key,
    required this.parameter,
    this.initiallyExpanded = true,
  });

  final ImpactedParameter parameter;
  final bool initiallyExpanded;

  @override
  State<ExpandableParameterCard> createState() =>
      _ExpandableParameterCardState();
}

class _ExpandableParameterCardState extends State<ExpandableParameterCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: _expanded,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.tileSurface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  color: AppColors.accentAmber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.parameter.title,
                      style: AppTypography.cardTitle,
                    ),
                    // Size transition keeps the reveal smooth without the text
                    // reflowing mid-animation.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      alignment: Alignment.topLeft,
                      child: _expanded
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                widget.parameter.description,
                                style: AppTypography.cardSubtitle,
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              AnimatedRotation(
                duration: const Duration(milliseconds: 220),
                turns: _expanded ? 0.5 : 0,
                child: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
