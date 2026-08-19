import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../genotype/genotype_view.dart';
import '../phenotype/phenotype_view.dart';

/// Root screen: ambient backdrop, header, mode tabs and the active half.
///
/// The two halves are swapped through an [AnimatedSwitcher] so the change of
/// mode reads as a cross-fade rather than a page rebuild.
class HubShell extends ConsumerWidget {
  const HubShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(hubModeProvider);
    final data = ref.watch(hubDataProvider);

    return Scaffold(
      body: AmbientBackground(
        tint: ref.watch(ambientTintProvider),
        child: SafeArea(
          bottom: false,
          child: data.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _LoadFailure(error: error),
            data: (_) => Column(
              children: [
                Padding(
                  padding: AppTheme.screenPadding,
                  child: HubHeader(
                    title: mode == HubMode.genotype ? 'Genotype' : 'Phenotype',
                    trailing: GlyphButton(
                      asset: 'assets/icons/icon_molecule.png',
                      onTap: () => _toggleMode(ref, mode),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: AppTheme.screenPadding,
                  child: ModeTabs(
                    mode: mode,
                    onChanged: (next) =>
                        ref.read(hubModeProvider.notifier).state = next,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: mode == HubMode.genotype
                        ? const GenotypeView(key: ValueKey('genotype'))
                        : const PhenotypeView(key: ValueKey('phenotype')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleMode(WidgetRef ref, HubMode current) =>
      ref.read(hubModeProvider.notifier).state = current == HubMode.genotype
      ? HubMode.phenotype
      : HubMode.genotype;
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Could not load health data.\n$error',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
