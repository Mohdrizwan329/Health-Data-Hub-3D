import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Registry mapping the JSON `icon` keys onto bundled glyphs.
///
/// Keeping this here means the data file never references Dart symbols.
abstract final class HubIcons {
  static const _assets = {
    'molecule': 'assets/icons/icon_molecule.png',
    'pulse': 'assets/icons/icon_pulse.png',
  };

  static String? assetFor(String? key) => _assets[key];

  static IconData fallbackFor(String? key) => switch (key) {
    'blood' => Icons.water_drop_outlined,
    'organ' => Icons.favorite_border,
    'pulse' => Icons.monitor_heart_outlined,
    _ => Icons.hub_outlined,
  };
}

/// Row used inside the disclosure panels: glyph tile, title and description.
class HubSectionCard extends StatelessWidget {
  const HubSectionCard({
    super.key,
    required this.title,
    this.subtitle = '',
    this.icon,
    this.selected = false,
    this.accent = AppColors.accentCyan,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String? icon;
  final bool selected;
  final Color accent;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final asset = HubIcons.assetFor(icon);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: selected
                ? Colors.black.withValues(alpha: 0.72)
                : AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent : Colors.transparent,
              width: 1.4,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.tileSurface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(11),
                child: asset != null
                    ? Image.asset(asset, color: accent, fit: BoxFit.contain)
                    : Icon(HubIcons.fallbackFor(icon), color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.cardTitle),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(subtitle, style: AppTypography.cardSubtitle),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
