import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Two-up pill selector with a sliding thumb.
///
/// Drives both the Genotype / Phenotype switch and the Dopamine / Serotonin
/// switch, which differ only in accent and label size.
class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.thumbColor = AppColors.surfaceHigh,
    this.height = 54,
    this.fontSize = 18,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Fill of the sliding thumb; the hormone toggle uses a bright green.
  final Color thumbColor;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    assert(labels.length == 2, 'the design only ever shows two segments');
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: selectedIndex == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: constraints.maxWidth / 2,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: thumbColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final (i, label) in labels.indexed)
                    Expanded(
                      child: Semantics(
                        selected: i == selectedIndex,
                        button: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: AppTypography.screenTitle.copyWith(
                                fontSize: fontSize,
                                color: i == selectedIndex
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                              child: Text(label),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
