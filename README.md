# Health Data Hub

A Flutter implementation of the Health Data Hub designs — a genotype / phenotype
health explorer covering gene scores, hormone regulation, blood metrics and
per-organ strengths and weaknesses.

No backend: everything is driven by local sample JSON.

## Running

```bash
flutter pub get
flutter run
```

Tested against Flutter 3.38.9 / Dart 3.10.8.

```bash
flutter test      # 16 tests — navigation paths, widget behaviour, model parsing
dart analyze      # clean
```

## Screens

The designs resolve to four distinct screens (the eight exported frames are
these four in different interaction states):

| Screen | What it shows |
| --- | --- |
| **Genotype — Gene-to-Health** | DNA stage with selectable gene markers, genotype score dial, narrative, ABOUT, organwise strengths / weaknesses |
| **Genotype — Hormone Regulation** | Same stage driven by hormone markers, hormone score dial, RANGES legend |
| **Phenotype — Blood Metrics** | Blood-cell stage with reading callouts, Blood Sugar / Blood Pressure trend cards, Overall Blood Quality dial, blood table |
| **Organ Score Detail** | Reached by tapping an organwise tile — semicircular banded needle dial, RANGES, impacted-parameter cards |
| **Organ Condition Overview** | Reached from Phenotype → Organ Metrics → Heart / Lungs — annotated hero artwork, crimson condition dial, guidance card, strengths / weaknesses, risk assessment |
| **Health Conditions Overview** | Phenotype → Organ Metrics — annotated body figure, Dopamine / Serotonin switch, activity line chart, Hyperprolactinemia score card, immune dial and guidance |
| **Marker Detail** | Reached from a risk assessment row — banded needle dial on the amber wash, RANGES and impacted parameters |

## Structure

```
lib/
  app/            theme (colours, type ramp), providers, navigation, root widget
  data/
    models/       immutable domain models + JSON parsing
    sources/      local asset-bundle source
    repositories/ single entry point the UI depends on
  features/
    shell/        root scaffold, mode switching
    genotype/     gene + hormone sections, marker slot layout
    phenotype/    blood stage, trend cards, table, organ picker
    conditions/   per-organ condition overview (heart, lungs)
    gene_detail/  per-organ score detail
  widgets/
    painters/     CustomPainters (dials, spline chart, ambient glow)
    charts/       animated wrappers around those painters
    common/       reusable presentation widgets
assets/
  data/           sample JSON
  images/         artwork extracted from the design
  icons/          glyphs extracted from the design
  fonts/          bundled type
```

### State management

Riverpod. `hubDataProvider` loads and caches the sample data once;
`hubModeProvider`, `selectedGeneIdProvider`, `selectedHormoneIdProvider` and
`genotypeSectionProvider` hold selection state. Screens depend on the
repository rather than the asset bundle, so swapping in a network source would
not touch any widget.

### Navigation

Every drill-down resolves through one extension, `app/navigation.dart`, so a
tile, a risk row and an artwork hotspot all reach the same destination:

```
Hub ─┬─ Genotype ─── organwise tile ──────────────► Organ / marker detail
     └─ Phenotype ─┬─ Organ Metrics ─┬─ organ row ─► Organ condition ─┬─ risk row ──────► Marker detail
                   │                 │              (heart / lungs)   ├─ strength tile ─► Marker detail
                   │                 │                                └─ "View in Details" hotspot
                   │                 └─ body figure hotspot ──────────► Organ condition / marker detail
                   ├─ Blood Metrics
                   └─ Hormone
```

Screens that the sample data does not spell out are filled from
`marker_template` in the JSON, so no tile or row is a dead end: a bespoke
payload wins where one exists (`Mentzer`), and the template stands in
elsewhere, carrying the tapped reading onto the gauge.

The design bakes its annotation callouts into the artwork, so selection is
expressed as invisible regions measured against the image (`ArtHotspot` +
`ArtHotspotLayer`) rather than as redrawn widgets. Regions carry semantics
labels for screen readers and breathe a barely-there halo where they are meant
to invite a tap.

### Custom painting

Everything gauge- and chart-shaped is hand-painted rather than pulled from a
charting package:

- `ScoreGaugePainter` — the two circular dials. Both sweep 270° from the
  lower-left (shared in `GaugeGeometry`) and differ only in how progress reads:
  the genotype dial uses a needle over long radial bars, the blood-quality dial a
  thick capped arc with a knob. Tick rings, bar rings and label rings are all
  derived from the radius, so one painter serves any size.
- `NeedleGaugePainter` — the semicircular banded dial, with captions laid out
  around the rim and a tapered pivoting needle.
- `SplineChartPainter` — Catmull-Rom through the samples, converted to cubic
  Béziers, with a gradient fill and a left-to-right reveal.
- `ActivityChartPainter` — the activity chart: a Catmull-Rom spline stroked with
  a horizontal gradient (green warm-up → amber peak → red recovery), dotted
  grid, dashed reference line and marked samples.
- `AmbientGlowPainter` — the layered background washes. Four tints: green for
  genotype and the body overview, blue for blood, crimson for organ conditions,
  amber for marker details.
- `ArcGlowPainter` — the bowed glow closing off the condition dial.
- `MiniMeterPainter` — the half-dial on the score summary card.

The circular dial is one painter across three looks: amber genotype, green
blood-quality and crimson condition. The condition dial adds a separate rim
colour, accent-tinted graduations and a halo around the centre well.

### Animation

Motion is tied to meaning rather than decoration:

- Score dials fill on entry and re-animate **from their current reading** when
  the selection changes, so switching gene reads as a transition.
- The stage subject drifts on a slow sine and lifts in on first build; the
  platform stays put so the scene does not wobble. Reduced-motion is honoured.
- Marker chips scale and light their rim on selection.
- Mode switching cross-fades; the organ detail pushes with a slide-up route.

### Responsiveness

Legends, organwise tiles and trend cards reflow by measuring available width
rather than switching on device class. The blood table keeps its four columns
and scrolls horizontally when the viewport is too narrow to hold them. System
text scaling is clamped to a range the layout can absorb.

## Sample data

`assets/data/hub_data.json` carries the copy and figures shown in the designs
(SLC6A4 at 66%, Dopamine at 76%, Overall Blood Quality at 73%, Heart Attack at
30%, Lungs Condition at 66%, the organwise percentages, the blood panel and the
risk assessment rows), plus additional genes and hormones so the marker
selection has somewhere to go.

## Notes on fidelity

Two things worth flagging:

- **Fonts.** The design exports have their type flattened to outlines, so the
  original family names are not recoverable from them. The bundled faces are
  close matches — Orbitron for the techno headings, Nunito Sans for body copy,
  Share Tech Mono for the organwise labels. Swapping in the real families is a
  drop-in change to `assets/fonts/` and `AppFonts`.
- **Artwork.** The DNA helix, platform, blood-cell and organ renders were
  extracted from the design exports and given alpha derived from luminance so
  they composite over any background. On the DNA and blood stages the labels
  were painted out and re-drawn as interactive widgets. On the organ heroes the
  annotation boxes are kept as part of the artwork — cutting them out damaged
  the organ beneath — with invisible hotspots measured against the image over
  "View in Details" and, on the body figure, over each callout and the chest.

## Coverage

Every screen in the supplied exports is implemented, and every interactive
element in them leads somewhere: body-figure callouts, organ rows, organwise
tiles, risk rows and the "View in Details" links were each walked on device.

The organ picker is rendered as rows inside the section panel rather than the
design's sliding drawer, and condition data ships for Heart and Lungs — adding
another organ is a JSON entry plus its artwork, with no code change. The
design's drawer also lists kidneys, Brain, Bones, Stomach and Intestine, for
which the exports contain no screens.
