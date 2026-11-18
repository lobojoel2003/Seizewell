// Renders the README / store screenshots from the real widgets, with real
// fonts and six months of fictional sample data.
//
//   flutter test screenshots/generate_test.dart
//
// Output: docs/images/screens/*.png (780×1688, 2× of a 390×844 phone).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seizewell/src/data/demo_data.dart';
import 'package:seizewell/src/data/settings_store.dart';
import 'package:seizewell/src/ui/insights/insights_screen.dart';

import '../test/helpers.dart';

const _outDir = 'docs/images/screens';
final _boundary = GlobalKey();

Future<void> _loadFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, Object?>>()) {
    final loader = FontLoader(family['family']! as String);
    for (final font
        in (family['fonts']! as List).cast<Map<String, Object?>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pump(const Duration(milliseconds: 300));
  final boundary =
      _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_outDir/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
  });
}

Future<TestHarness> _setUp(
  WidgetTester tester, {
  bool demo = true,
  bool onboarded = true,
  AppThemeMode theme = AppThemeMode.light,
}) async {
  final h = await TestHarness.create(
    onboarded: onboarded,
    now: DateTime(2026, 11, 18, 9, 41),
  );
  if (demo) await loadDemoData(h.db, h.settings, today: h.clock.now());
  await h.settings.setThemeMode(theme);
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  tester.view.padding = const FakeViewPadding(top: 141, bottom: 60);
  tester.view.viewPadding = const FakeViewPadding(top: 141, bottom: 60);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  // Phones are touch devices: no keyboard focus rings.
  FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundary,
      child: Builder(builder: (_) => _app(h)),
    ),
  );
  await h.settle(tester, 8);
  return h;
}

Widget _app(TestHarness h) => h.buildApp();

void main() {
  setUpAll(_loadFonts);

  testWidgets('home', (tester) async {
    final h = await _setUp(tester);
    await _shot(tester, '01-home');
    await h.dispose(tester);
  });

  testWidgets('timer', (tester) async {
    final h = await _setUp(tester);
    await tester.tap(find.byKey(const Key('start-seizure')));
    await h.settle(tester);
    h.clock.advance(const Duration(minutes: 1, seconds: 23));
    await h.settle(tester, 3);
    await _shot(tester, '02-timer');

    h.clock.advance(const Duration(minutes: 4, seconds: 19));
    await h.settle(tester, 8);
    await _shot(tester, '03-timer-alert');

    await tester.tap(find.byKey(const Key('rescue-given')));
    await h.settle(tester);
    h.clock.advance(const Duration(minutes: 1, seconds: 12));
    await h.settle(tester, 3);
    await _shot(tester, '04-rescue');

    h.clock.advance(const Duration(seconds: 31));
    await tester.tap(find.byKey(const Key('end-seizure')));
    await h.settle(tester);
    await _shot(tester, '05-recorded');

    await tester.tap(find.text('Add details now'));
    await h.settle(tester);
    await h.tapInList(tester, find.text('Focal → bilateral'));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 1000));
    await h.settle(tester);
    await _shot(tester, '06-details');
    await h.dispose(tester);
  });

  testWidgets('diary', (tester) async {
    final h = await _setUp(tester);
    await tester.tap(find.text('Diary'));
    await h.settle(tester);
    await _shot(tester, '07-diary');
    await h.dispose(tester);
  });

  testWidgets('insights', (tester) async {
    final h = await _setUp(tester);
    await tester.tap(find.text('Insights'));
    await h.settle(tester);
    await tester.tap(find.text(insightRanges[180]!));
    await h.settle(tester);
    await _shot(tester, '08-insights');
    final list = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(InsightsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    list.position.jumpTo(452);
    await h.settle(tester);
    await _shot(tester, '09-insights-calendar');
    list.position.jumpTo(1118);
    await h.settle(tester);
    await _shot(tester, '10-insights-trend');
    await h.dispose(tester);
  });

  testWidgets('meds', (tester) async {
    final h = await _setUp(tester);
    await tester.tap(find.text('Meds'));
    await h.settle(tester);
    await _shot(tester, '11-medications');
    await h.dispose(tester);
  });

  testWidgets('more', (tester) async {
    final h = await _setUp(tester);
    await tester.tap(find.text('More'));
    await h.settle(tester);
    await _shot(tester, '12-more');
    if (Platform.environment['SEIZEWELL_EXTRA_SHOTS'] != null) {
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -900));
      await h.settle(tester);
      await _shot(tester, '12b-more-bottom');
    }
    await h.dispose(tester);
  });

  testWidgets('onboarding', (tester) async {
    final h = await _setUp(tester, demo: false, onboarded: false);
    await _shot(tester, '13-welcome');
    await h.dispose(tester);
  });

  testWidgets('dark home', (tester) async {
    final h = await _setUp(tester, theme: AppThemeMode.dark);
    await _shot(tester, '14-home-dark');
    await h.dispose(tester);
  });

  testWidgets('lock', (tester) async {
    final h = await _setUp(tester);
    await h.settings.setAppLockEnabled(true);
    h.auth.succeed = false;
    h.services.lock.lock();
    await h.settle(tester);
    await _shot(tester, '15-locked');
    await h.dispose(tester);
  });
}
