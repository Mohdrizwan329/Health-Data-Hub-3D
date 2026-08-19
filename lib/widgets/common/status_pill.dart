import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';

/// Small outlined or filled chip carrying a status word.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.filled = false,
  });

  final String label;
  final Color color;

  /// Filled reads as a tag; outlined reads as a badge, matching the design's
  /// two treatments.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.20) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: filled ? 0.35 : 0.95),
        ),
      ),
      child: Text(label, style: AppTypography.label.copyWith(color: color)),
    );
  }
}
