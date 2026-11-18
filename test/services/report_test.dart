import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seizewell/src/data/connection.dart';
import 'package:seizewell/src/data/database.dart';
import 'package:seizewell/src/data/demo_data.dart';
import 'package:seizewell/src/data/queries.dart';
import 'package:seizewell/src/data/settings_store.dart';
import 'package:seizewell/src/domain/stats.dart';
import 'package:seizewell/src/services/report/clinic_report.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final today = DateTime(2026, 11, 18);

  late AppDatabase db;
  late SettingsStore settings;
  late ReportFonts fonts;

  setUp(() async {
    db = openTestDatabase();
    settings = await SettingsStore.load(db, countryCode: 'US');
    await loadDemoData(db, settings, today: today);
    fonts = await ReportFonts.load(rootBundle);
  });

  tearDown(() => db.close());

  Future<Uint8List> build(
    int days, {
    PaperSize paper = PaperSize.letter,
  }) async {
    final range = DateRange.lastDays(days, today);
    final all = await db.allSeizures();
    final stats = SeizureStats.compute(
      range: range,
      seizures: all,
      previousPeriod: all,
      sleep: await db.allSleep(),
    );
    return buildClinicReport(
      ReportData(
        stats: stats,
        medications: await db.allMedications(),
        medicationChanges: await db.allMedicationChanges(),
        generatedAt: today,
        appVersion: '1.0.0',
        patientName: settings.patientName,
        dateOfBirth: settings.dateOfBirth,
        paperSize: paper,
      ),
      fonts,
    );
  }

  for (final days in [30, 90, 180, 365]) {
    test('builds a single-page report for $days days', () async {
      final bytes = await build(days);
      final text = String.fromCharCodes(bytes);
      expect(text.startsWith('%PDF-'), isTrue);
      expect(RegExp(r'/Type\s*/Page\b').allMatches(text).length, 1);

      final out = Platform.environment['SEIZEWELL_REPORT_OUT'];
      if (out != null) {
        await File('$out/report-$days.pdf').writeAsBytes(bytes);
      }
    });
  }

  test('A4 report is also one page', () async {
    final bytes = await build(90, paper: PaperSize.a4);
    expect(
      RegExp(r'/Type\s*/Page\b').allMatches(String.fromCharCodes(bytes)).length,
      1,
    );
  });

  test('empty diary still renders', () async {
    final empty = openTestDatabase();
    final stats = SeizureStats.compute(
      range: DateRange.lastDays(90, today),
      seizures: const [],
    );
    final bytes = await buildClinicReport(
      ReportData(
        stats: stats,
        medications: const [],
        medicationChanges: const [],
        generatedAt: today,
        appVersion: '1.0.0',
      ),
      fonts,
    );
    expect(bytes.length, greaterThan(1000));
    await empty.close();
  });
}
