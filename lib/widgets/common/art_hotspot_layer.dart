import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Pins invisible tap targets over hero artwork.
///
/// The designs draw their callout boxes into the artwork itself, so selection
/// cannot be a widget without redrawing the design. Instead each region is
/// measured against the image and laid over it, optionally breathing a soft
/// halo so a tappable annotation reads as tappable.
class ArtHotspotLayer extends StatelessWidget {
  const ArtHotspotLayer({
    super.key,
    required this.hotspots,
    required this.onSelect,
    required this.child,
  });

  final List<ArtHotspot> hotspots;
  final ValueChanged<ArtHotspot> onSelect;

  /// The artwork, which also sizes this layer.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (hotspots.isEmpty) return child;
    return Stack(
      children: [
        child,
        for (final hotspot in hotspots)
          Positioned.fill(
            child: Align(
              alignment: hotspot.alignment,
              child: FractionallySizedBox(
                widthFactor: hotspot.widthFactor,
                heightFactor: hotspot.heightFactor,
                child: _HotspotTarget(
                  hotspot: hotspot,
                  onTap: () => onSelect(hotspot),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HotspotTarget extends StatefulWidget {
  const _HotspotTarget({required this.hotspot, required this.onTap});

  final ArtHotspot hotspot;
  final VoidCallback onTap;

  @override
  State<_HotspotTarget> createState() => _HotspotTargetState();
}

class _HotspotTargetState extends State<_HotspotTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _halo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  bool _pressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!widget.hotspot.pulse || reduceMotion) {
      _halo.stop();
    } else if (!_halo.isAnimating) {
      _halo.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _halo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.hotspot.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _halo,
          builder: (context, _) {
            // Barely-there wash: enough to hint at a target, not enough to
            // repaint the artwork's own callout.
            final glow = widget.hotspot.pulse ? 0.04 + _halo.value * 0.05 : 0.0;
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: _pressed ? 0.14 : glow),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}
