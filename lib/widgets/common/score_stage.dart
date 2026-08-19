import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import 'art_hotspot_layer.dart';

/// A marker pinned over the stage artwork.
@immutable
class StageMarker {
  const StageMarker({required this.alignment, required this.child});

  final Alignment alignment;
  final Widget child;
}

/// Composes the hero artwork: a hovering subject above the lit platform, with
/// markers pinned around it.
///
/// The subject drifts on a slow sine so the scene feels alive while idle; the
/// platform stays put so the whole thing does not appear to wobble.
class ScoreStage extends StatefulWidget {
  const ScoreStage({
    super.key,
    required this.artAsset,
    required this.markers,
    this.hotspots = const [],
    this.onHotspot,
    this.artWidthFactor = 0.56,
    this.platformWidthFactor = 0.70,
    this.aspectRatio = 1.02,
    this.artAlignment = const Alignment(0, -0.34),
    this.platformAlignment = const Alignment(0, 0.66),
  });

  /// Foreground subject — the DNA helix or the blood-cell cluster.
  final String artAsset;
  final List<StageMarker> markers;

  /// Tap targets measured against the artwork — the annotations the design
  /// bakes into the image.
  final List<ArtHotspot> hotspots;
  final ValueChanged<ArtHotspot>? onHotspot;
  final double artWidthFactor;
  final double platformWidthFactor;
  final double aspectRatio;
  final Alignment artAlignment;

  /// Tuned so the subject's beam lands on the platform rather than floating
  /// above it.
  final Alignment platformAlignment;

  static const platformAsset = 'assets/images/score_platform.png';

  @override
  State<ScoreStage> createState() => _ScoreStageState();
}

class _ScoreStageState extends State<ScoreStage> with TickerProviderStateMixin {
  /// Slow perpetual drift that keeps the scene from feeling static.
  late final AnimationController _idle;

  /// One-shot fade and lift when the stage first appears.
  late final AnimationController _entry;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _entry.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honour reduced-motion, and keep the perpetual ticker out of tests where
    // it would stop `pumpAndSettle` from ever settling.
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _idle.stop();
    } else if (!_idle.isAnimating) {
      _idle.repeat();
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Platform, seated near the base of the stage.
              Align(
                alignment: widget.platformAlignment,
                child: Image.asset(
                  ScoreStage.platformAsset,
                  width: width * widget.platformWidthFactor,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              // Hovering subject.
              Align(
                alignment: widget.artAlignment,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_idle, _entry]),
                  builder: (context, child) {
                    final bob = math.sin(_idle.value * 2 * math.pi) * 6.0;
                    final entered = Curves.easeOutCubic.transform(_entry.value);
                    return Transform.translate(
                      offset: Offset(0, bob + (1 - entered) * 18),
                      child: Opacity(opacity: entered, child: child),
                    );
                  },
                  child: ArtHotspotLayer(
                    hotspots: widget.onHotspot == null
                        ? const []
                        : widget.hotspots,
                    onSelect: (hotspot) => widget.onHotspot?.call(hotspot),
                    child: Image.asset(
                      widget.artAsset,
                      width: width * widget.artWidthFactor,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
              for (final marker in widget.markers)
                Align(alignment: marker.alignment, child: marker.child),
            ],
          );
        },
      ),
    );
  }
}
