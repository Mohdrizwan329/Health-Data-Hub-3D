import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Back arrow, centred title and an optional trailing action.
class HubHeader extends StatelessWidget {
  const HubHeader({super.key, required this.title, this.trailing, this.onBack});

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack ?? () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, size: 26),
              color: AppColors.textPrimary,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
          Text(title, style: AppTypography.screenTitle),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing),
        ],
      ),
    );
  }
}

/// Circular outlined button holding a glyph, as used top-right of the header.
class GlyphButton extends StatelessWidget {
  const GlyphButton({
    super.key,
    required this.asset,
    this.onTap,
    this.size = 52,
    this.tint = AppColors.textPrimary,
  });

  final String asset;
  final VoidCallback? onTap;
  final double size;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: size * 0.7,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
            color: Colors.white.withValues(alpha: 0.04),
          ),
          padding: EdgeInsets.all(size * 0.26),
          child: Image.asset(asset, color: tint, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
