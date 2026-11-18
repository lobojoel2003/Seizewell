import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';
import 'package:printing/printing.dart';

import '../../app_services.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../../data/settings_store.dart';
import '../../domain/stats.dart';
import '../../services/platform_services.dart';
import '../../services/report/clinic_report.dart';
import '../insights/insights_screen.dart' show insightRanges;
import '../widgets/common.dart';

ReportFonts? _fonts;

/// Builds the clinic report PDF for the last [days] days.
Future<Uint8List> generateClinicReport(
  AppServices s, {
  required int days,
  PaperSize? paper,
}) async {
  final all = await s.db.allSeizures();
  final range = DateRange.lastDays(days, s.clock.now());
  final stats = SeizureStats.compute(
    range: range,
    seizures: all,
    previousPeriod: all,
    sleep: await s.db.allSleep(),
    prolongedThreshold: s.settings.plan.alertAfter,
  );
  _fonts ??= await ReportFonts.load(rootBundle);
  return buildClinicReport(
    ReportData(
      stats: stats,
      medications: await s.db.allMedications(),
      medicationChanges: await s.db.allMedicationChanges(),
      generatedAt: s.clock.now(),
      appVersion: s.info.version,
      patientName: s.settings.patientName,
      dateOfBirth: s.settings.dateOfBirth,
      paperSize: paper ?? s.settings.paperSize,
    ),
    _fonts!,
  );
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, this.initialDays = 90});

  final int initialDays;

  static Route<void> route({int initialDays = 90}) => MaterialPageRoute<void>(
    builder: (_) => ReportScreen(initialDays: initialDays),
  );

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late int _days = widget.initialDays;
  late PaperSize _paper = context.services.settings.paperSize;
  Future<(Uint8List, Uint8List?)>? _job;

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  void _rebuild() {
    final s = context.services;
    _job = () async {
      final pdf = await generateClinicReport(s, days: _days, paper: _paper);
      Uint8List? preview;
      try {
        await for (final page in Printing.raster(pdf, dpi: 96)) {
          preview = await page.toPng();
          break;
        }
      } on Object {
        preview = null;
      }
      return (pdf, preview);
    }();
  }

  String get _fileName {
    final now = context.services.clock.now();
    return 'seizewell-report-${formatIsoDate(now)}.pdf';
  }

  Future<void> _share(Uint8List pdf) async {
    await context.services.platform.shareFiles([
      ShareableFile(_fileName, pdf, 'application/pdf'),
    ], subject: 'Seizure diary report');
  }

  Future<void> _print(Uint8List pdf) async {
    try {
      await Printing.layoutPdf(onLayout: (_) async => pdf, name: _fileName);
    } on Object {
      if (mounted) showMessage(context, 'Printing is not available.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.services;
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic report')),
      body: FutureBuilder<(Uint8List, Uint8List?)>(
        future: _job,
        builder: (context, snap) {
          final ready =
              snap.connectionState == ConnectionState.done && snap.hasData;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              Text(
                'One page for the neurologist: a calendar heat map, counts '
                'by seizure type, and medication changes on the timeline.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SectionHeader('Period'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<int>(
                  segments: [
                    for (final e in insightRanges.entries)
                      ButtonSegment(value: e.key, label: Text(e.value)),
                  ],
                  selected: {_days},
                  showSelectedIcon: false,
                  onSelectionChanged: (v) => setState(() {
                    _days = v.first;
                    _rebuild();
                  }),
                ),
              ),
              const SectionHeader('Paper'),
              SegmentedButton<PaperSize>(
                segments: [
                  for (final p in PaperSize.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {_paper},
                showSelectedIcon: false,
                onSelectionChanged: (v) {
                  setState(() {
                    _paper = v.first;
                    _rebuild();
                  });
                  s.settings.setPaperSize(v.first);
                },
              ),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: _paper == PaperSize.a4 ? 210 / 297 : 8.5 / 11,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: !ready
                        ? const Center(child: CircularProgressIndicator())
                        : snap.data!.$2 == null
                        ? const Center(
                            child: Icon(
                              Icons.picture_as_pdf_rounded,
                              size: 64,
                              color: Colors.black26,
                            ),
                          )
                        : Image.memory(
                            snap.data!.$2!,
                            fit: BoxFit.contain,
                            semanticLabel: 'Preview of the clinic report',
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: ready ? () => _share(snap.data!.$1) : null,
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Share PDF'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: ready ? () => _print(snap.data!.$1) : null,
                icon: const Icon(Icons.print_rounded),
                label: const Text('Print'),
              ),
              const SizedBox(height: 16),
              Text(
                'The report is created on this phone. It is only shared '
                'when you choose to.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
