import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seizewell/src/data/demo_data.dart';

import 'package:seizewell/src/ui/report/report_screen.dart';

import '../helpers.dart';

void main() {
  Future<TestHarness> openMore(WidgetTester tester) async {
    final h = await TestHarness.create();
    await loadDemoData(h.db, h.settings, today: h.clock.now());
    await h.pump(tester);
    await tester.tap(find.text('More'));
    await h.settle(tester);
    return h;
  }

  testWidgets('clinic report is generated and shared as a PDF', (tester) async {
    // Asset loading does real I/O, which needs the real event loop.
    await tester.runAsync(loadReportFonts);
    final h = await openMore(tester);
    await tester.tap(find.text('Clinic report (PDF)'));
    await h.settle(tester, 20);

    await h.tapInList(tester, find.text('Share PDF'));
    await h.settle(tester);

    final file = h.platform.shared.single.single;
    expect(file.name, 'seizewell-report-2026-11-18.pdf');
    expect(file.mimeType, 'application/pdf');
    expect(ascii.decode(file.bytes.sublist(0, 5)), '%PDF-');

    await h.dispose(tester);
  });

  testWidgets('CSV and FHIR exports go to the share sheet', (tester) async {
    final h = await openMore(tester);
    await h.tapInList(tester, find.text('Export data'));
    await h.settle(tester);

    await tester.tap(find.text('Spreadsheet (CSV)'));
    await h.settle(tester);
    final csv = h.platform.shared.last;
    expect(csv.map((f) => f.name), [
      'seizewell-seizures-2026-11-18.csv',
      'seizewell-medications-2026-11-18.csv',
      'seizewell-sleep-2026-11-18.csv',
    ]);
    expect(utf8.decode(csv.first.bytes), startsWith('id,start,end'));

    await tester.tap(find.text('FHIR R4 (JSON)'));
    await h.settle(tester);
    final fhir = h.platform.shared.last.single;
    final bundle = jsonDecode(utf8.decode(fhir.bytes)) as Map<String, Object?>;
    expect(bundle['resourceType'], 'Bundle');
    expect((bundle['entry']! as List).length, greaterThan(100));

    await h.dispose(tester);
  });

  testWidgets('emergency plan edits show up on the timer', (tester) async {
    final h = await openMore(tester);
    await tester.tap(find.text('Emergency plan'));
    await h.settle(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Medication'),
      'Diazepam rectal gel',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await h.settle(tester);
    expect(h.settings.plan.rescueMedication, 'Diazepam rectal gel');

    await tester.tap(find.text('Today'));
    await h.settle(tester);
    await tester.tap(find.byKey(const Key('start-seizure')));
    await h.settle(tester);
    h.clock.advance(const Duration(minutes: 5));
    await h.settle(tester, 3);
    expect(find.textContaining('Diazepam rectal gel'), findsOneWidget);

    await h.dispose(tester);
  });
}
