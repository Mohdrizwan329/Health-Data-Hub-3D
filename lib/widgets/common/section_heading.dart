import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Techno-face heading with an optional circular disclosure button.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.onToggle,
    this.expanded = false,
    this.style,
  });

  final String title;
  final VoidCallback? onToggle;

  /// Rotates the chevron to point up when the panel below is open.
  final bool expanded;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(title, style: style ?? AppTypography.sectionTitle),
        ),
        if (onToggle != null) ...[
          const SizedBox(width: 12),
          _DisclosureButton(expanded: expanded, onTap: onToggle!),
        ],
      ],
    );
  }
}

class _DisclosureButton extends StatelessWidget {
  const _DisclosureButton({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: expanded,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.5),
            border: Border.all(
              color: AppColors.accentTeal.withValues(alpha: 0.75),
            ),
          ),
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 240),
            turns: expanded ? 0.5 : 0,
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
