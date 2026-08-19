import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthdatahub/app/app.dart';
import 'package:healthdatahub/app/providers.dart';
import 'package:healthdatahub/data/models/models.dart';

import 'support/hub_fixture.dart';

final HubData fixture = loadHubFixture();

/// Mounts the app at the design's viewport with animations disabled and the
/// sample data injected, so `pumpAndSettle` has a finite amount to settle.
Future<void> pumpHub(WidgetTester tester) async {
  tester.view
    ..devicePixelRatio = 3
    ..physicalSize = const Size(402 * 3, 874 * 3);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [hubDataProvider.overrideWith((ref) async => fixture)],
      child: const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: HealthDataHubApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens on the genotype half with a gene selected', (
    tester,
  ) async {
    await pumpHub(tester);

    expect(find.text('Gene-to-Health Overview'), findsOneWidget);
    expect(find.textContaining('Genotype Score'), findsWidgets);
    expect(find.text('SLC6A4'), findsWidgets);
  });

  testWidgets('switching to phenotype shows the blood overview', (
    tester,
  ) async {
    await pumpHub(tester);

    await tester.tap(find.text('Phenotype').first);
    await tester.pumpAndSettle();

    // The gauge and table sit below the fold in a lazy sliver list.
    await tester.scrollUntilVisible(
      find.text('Overall Blood Quality'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Overall Blood Quality'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Blood Health Overview'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Hemoglobin (Hb)'), findsOneWidget);
  });

  testWidgets('tapping a marker switches the active gene', (tester) async {
    await pumpHub(tester);

    await tester.tap(find.text('OXTR').first);
    await tester.pumpAndSettle();

    expect(find.text('(Oxytocin Receptor Gene)'), findsWidgets);
  });

  testWidgets('organ metrics leads into a condition overview', (tester) async {
    await pumpHub(tester);

    await tester.tap(find.text('Phenotype').first);
    await tester.pumpAndSettle();

    // Open the section panel and choose Organ Metrics.
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Organ Metrics'));
    await tester.pumpAndSettle();

    expect(find.text('Heart'), findsOneWidget);
    expect(find.text('Lungs'), findsOneWidget);

    await tester.tap(find.text('Heart'));
    await tester.pumpAndSettle();

    expect(find.text('Heart Conditions Overview'), findsOneWidget);
    expect(find.text('Heart Attack (Myocardial Infarction)'), findsOneWidget);

    // The guidance card and risk rows sit below the fold.
    await tester.scrollUntilVisible(
      find.text('Weakness :'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Weakness :'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Chronic Heart Disease Risk Assessment'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Mentzer'), findsOneWidget);
  });

  testWidgets('a risk row opens its marker detail', (tester) async {
    await pumpHub(tester);
    await tester.tap(find.text('Phenotype').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Organ Metrics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Heart'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Mentzer'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    // scrollUntilVisible only guarantees the sliver built the row, not that it
    // is on screen, so bring it fully into view before tapping.
    await tester.ensureVisible(find.text('Mentzer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mentzer'));
    await tester.pumpAndSettle();

    expect(find.text('36.7'), findsWidgets);
    expect(find.text('optimal'), findsOneWidget);
    expect(find.text('RANGES'), findsOneWidget);
  });

  testWidgets('the body figure selects an organ', (tester) async {
    await pumpHub(tester);
    await tester.tap(find.text('Phenotype').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Organ Metrics'));
    await tester.pumpAndSettle();

    // The "Chronics Lungs Problem" callout is painted into the artwork; the
    // hotspot over it is what carries the user into the lungs screen.
    final lungsHotspot = find.bySemanticsLabel('Chronic lungs problem');
    await tester.ensureVisible(lungsHotspot);
    await tester.tap(lungsHotspot);
    await tester.pumpAndSettle();

    expect(find.text('Lungs Conditions Overview'), findsOneWidget);
  });

  testWidgets('a strength tile opens its marker detail', (tester) async {
    await pumpHub(tester);

    await tester.scrollUntilVisible(
      find.text('kidney'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.text('kidney'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('kidney'));
    await tester.pumpAndSettle();

    // No bespoke payload for this organ, so the templated screen stands in.
    expect(find.text('SLC6A4 kidney Score'), findsOneWidget);
    expect(find.text('RANGES'), findsOneWidget);
  });

  group('ScoreBand', () {
    test('follows the documented thresholds', () {
      expect(ScoreBand.forScore(92), ScoreBand.high);
      expect(ScoreBand.forScore(80), ScoreBand.high);
      expect(ScoreBand.forScore(66), ScoreBand.moderate);
      expect(ScoreBand.forScore(50), ScoreBand.moderate);
      expect(ScoreBand.forScore(49), ScoreBand.low);
    });
  });

  group('models', () {
    test('organ score formats to two decimals', () {
      const score = OrganScore(label: 'Heart', percent: 76.96);
      expect(score.formatted, '76.96 %');
    });

    test('gene marker resolves its organ detail case-insensitively', () {
      final gene = fixture.genotype.geneById('slc6a4');
      expect(gene.detailFor('heart'), isNotNull);
      expect(gene.detailFor('Spleen'), isNull);
    });

    test('sample data parses fully', () {
      expect(fixture.genotype.genes, hasLength(6));
      expect(fixture.genotype.hormones, hasLength(4));
      expect(fixture.phenotype.metrics, hasLength(5));
      expect(fixture.phenotype.overallQuality, 73);
      expect(fixture.conditions, hasLength(2));
    });

    test('heart condition carries its guidance and risk rows', () {
      final heart = fixture.conditionById('heart')!;
      expect(heart.score, 30);
      expect(heart.numbered, isTrue);
      expect(heart.recommendations, hasLength(7));
      expect(heart.risks, hasLength(6));
      expect(heart.strengths, hasLength(6));
      expect(heart.weaknesses, hasLength(6));
      expect(heart.risks.first.tone, RiskTone.amber);
      // Every risk row opens a screen: bespoke where the data has one,
      // templated otherwise.
      expect(fixture.detailFor('Mentzer').unit, 'mcg/dl');
      expect(fixture.detailFor('Immunoglobulim E2', score: 69).score, 69);
    });

    test('artwork hotspots resolve to a screen', () {
      expect(fixture.health.hotspots, isNotEmpty);
      for (final hotspot in fixture.health.hotspots) {
        expect(fixture.targetOf(hotspot.target), isNotNull);
      }
      final heart = fixture.conditionById('heart')!;
      expect(heart.hotspots, hasLength(1));
      expect(fixture.targetOf(heart.hotspots.single.target), isA<OrganDetail>());
    });

    test('health overview parses its series and guidance', () {
      final health = fixture.health;
      expect(health.series, hasLength(2));
      expect(health.seriesAt(0).points, isNotEmpty);
      expect(health.summary.percent, 95);
      expect(health.immuneScore, 30);
      expect(health.guidanceItems, hasLength(3));
    });

    test('mentzer marker resolves by name', () {
      final marker = fixture.markerNamed('mentzer');
      expect(marker, isNotNull);
      expect(marker!.unit, 'mcg/dl');
      expect(marker.tint, 'amber');
      expect(marker.bands, hasLength(6));
    });

    test('lungs condition uses a bulleted list', () {
      final lungs = fixture.conditionById('lungs')!;
      expect(lungs.numbered, isFalse);
      expect(lungs.strengths, hasLength(6));
    });
  });
}
