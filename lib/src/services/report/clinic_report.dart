import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show AssetBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/brand.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../../data/settings_store.dart';
import '../../domain/stats.dart';
import '../../domain/types.dart';

class ReportFonts {
  const ReportFonts({
    required this.regular,
    required this.medium,
    required this.bold,
  });

  final pw.Font regular;
  final pw.Font medium;
  final pw.Font bold;

  static Future<ReportFonts> load(AssetBundle bundle) async {
    Future<pw.Font> f(String name) async =>
        pw.Font.ttf(await bundle.load('assets/fonts/Inter-$name.ttf'));
    return ReportFonts(
      regular: await f('Regular'),
      medium: await f('Medium'),
      bold: await f('Bold'),
    );
  }
}

class ReportData {
  const ReportData({
    required this.stats,
    required this.medications,
    required this.medicationChanges,
    required this.generatedAt,
    required this.appVersion,
    this.patientName = '',
    this.dateOfBirth,
    this.paperSize = PaperSize.letter,
  });

  final SeizureStats stats;
  final List<Medication> medications;
  final List<MedicationChangeEntry> medicationChanges;
  final DateTime generatedAt;
  final String appVersion;
  final String patientName;
  final DateTime? dateOfBirth;
  final PaperSize paperSize;

  List<MedicationChangeEntry> get changesInRange {
    final list =
        medicationChanges
            .where((c) => stats.range.contains(c.change.date))
            .toList()
          ..sort((a, b) {
            final d = a.change.date.compareTo(b.change.date);
            return d != 0 ? d : a.change.id.compareTo(b.change.id);
          });
    return list;
  }
}

PdfColor _c(int argb) => PdfColor.fromInt(argb);

final _ink = _c(Brand.ink);
final _muted = _c(Brand.inkMuted);
final _line = _c(Brand.line);
final _violet = _c(Brand.violet);
final _soft = _c(Brand.violetSoft);

/// Builds the one-page clinic report.
Future<Uint8List> buildClinicReport(ReportData data, ReportFonts fonts) {
  final doc = pw.Document(
    title: 'Seizure diary report',
    author: 'Seizewell',
    creator: 'Seizewell ${data.appVersion}',
    subject: data.patientName.isEmpty
        ? 'Seizure diary'
        : 'Seizure diary — ${data.patientName}',
  );
  final format = data.paperSize == PaperSize.a4
      ? PdfPageFormat.a4
      : PdfPageFormat.letter;
  const margin = 30.0;
  final width = format.width - margin * 2;

  doc.addPage(
    pw.Page(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(margin),
      theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold)
          .copyWith(
            defaultTextStyle: pw.TextStyle(
              font: fonts.regular,
              fontBold: fonts.bold,
              fontSize: 8.5,
              color: _ink,
              lineSpacing: 1.5,
            ),
          ),
      build: (context) {
        final s = data.stats;
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _header(data, fonts),
            pw.SizedBox(height: 12),
            _statTiles(s, fonts, width),
            pw.SizedBox(height: 6),
            _secondaryStats(s),
            pw.SizedBox(height: 14),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: width * 0.6,
                  child: _section(
                    'Calendar',
                    fonts,
                    _heatMap(s, fonts, width * 0.6),
                    trailing: _heatLegend(),
                  ),
                ),
                pw.SizedBox(width: width * 0.04),
                pw.SizedBox(
                  width: width * 0.36,
                  child: _section(
                    'By seizure type',
                    fonts,
                    _typeBars(s, fonts, width * 0.36),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 14),
            _section(
              s.bucketDays == 1
                  ? 'Seizures per day, with medication changes'
                  : 'Seizures per week, with medication changes',
              fonts,
              _timeline(data, fonts, width),
            ),
            pw.SizedBox(height: 14),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _section('Common triggers', fonts, _triggers(s)),
                ),
                pw.SizedBox(width: 14),
                pw.Expanded(child: _section('Sleep', fonts, _sleep(s))),
                pw.SizedBox(width: 14),
                pw.Expanded(
                  flex: 2,
                  child: _section(
                    'Current medications',
                    fonts,
                    _medications(data),
                  ),
                ),
              ],
            ),
            pw.Spacer(),
            _footer(data),
          ],
        );
      },
    ),
  );
  return doc.save();
}

pw.Widget _header(ReportData data, ReportFonts fonts) {
  final s = data.stats;
  pw.Widget field(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 1.5),
    child: pw.RichText(
      textAlign: pw.TextAlign.right,
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label  ',
            style: pw.TextStyle(color: _muted, fontSize: 8),
          ),
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(font: fonts.medium, fontSize: 8.5),
          ),
        ],
      ),
    ),
  );

  return pw.Column(
    children: [
      pw.Container(
        height: 4,
        decoration: pw.BoxDecoration(
          gradient: pw.LinearGradient(
            colors: [_c(Brand.violetDeep), _violet, _c(0xFF9B86F0)],
          ),
          borderRadius: pw.BorderRadius.circular(2),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Seizure diary report',
                  style: pw.TextStyle(
                    font: fonts.bold,
                    fontSize: 18,
                    color: _c(Brand.violetDeep),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Patient-reported data recorded with Seizewell',
                  style: pw.TextStyle(color: _muted, fontSize: 8.5),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              field(
                'Patient',
                data.patientName.isEmpty ? '—' : data.patientName,
              ),
              if (data.dateOfBirth != null)
                field('Date of birth', formatDate(data.dateOfBirth!)),
              field(
                'Period',
                '${formatRange(s.range.start, s.range.lastDay)} '
                    '(${s.range.days} days)',
              ),
              field('Generated', formatDate(data.generatedAt)),
            ],
          ),
        ],
      ),
    ],
  );
}

pw.Widget _statTiles(SeizureStats s, ReportFonts fonts, double width) {
  final change = s.changeVsPrevious;
  String? changeText;
  if (s.previousTotal != null) {
    if (change == null) {
      changeText = s.previousTotal == 0 ? 'none in previous period' : null;
    } else {
      final pct = (change * 100).round();
      changeText = pct == 0
          ? 'same as previous period'
          : '${pct > 0 ? '+' : '−'}${pct.abs()}% vs previous ${s.range.days} d';
    }
  }
  final tiles = <(String, String, String?)>[
    ('Seizures', '${s.total}', changeText),
    ('Seizure days', '${s.seizureDays}', 'of ${s.range.days}'),
    ('Per 30 days', s.perThirtyDays.toStringAsFixed(1), null),
    ('Longest', formatDurationShort(s.longest), null),
    ('≥ ${s.prolongedThreshold.inMinutes} min', '${s.prolonged}', 'prolonged'),
    ('Rescue doses', '${s.rescueDoses}', null),
  ];
  const gap = 6.0;
  final tileWidth = (width - gap * (tiles.length - 1)) / tiles.length;
  return pw.Row(
    children: [
      for (var i = 0; i < tiles.length; i++) ...[
        if (i > 0) pw.SizedBox(width: gap),
        pw.Container(
          width: tileWidth,
          padding: const pw.EdgeInsets.fromLTRB(8, 6, 8, 6),
          decoration: pw.BoxDecoration(
            color: i == 0 ? _soft : null,
            border: pw.Border.all(color: i == 0 ? _soft : _line, width: 0.8),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                tiles[i].$1,
                style: pw.TextStyle(color: _muted, fontSize: 7.5),
              ),
              pw.Text(
                tiles[i].$2,
                style: pw.TextStyle(
                  font: fonts.bold,
                  fontSize: 15,
                  color: i == 0 ? _c(Brand.violetDeep) : _ink,
                ),
              ),
              pw.Text(
                tiles[i].$3 ?? ' ',
                style: pw.TextStyle(color: _muted, fontSize: 6.5),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

pw.Widget _secondaryStats(SeizureStats s) {
  final parts = [
    'Median duration ${formatDurationShort(s.median)}',
    'Longest seizure-free stretch ${plural(s.longestSeizureFreeDays, 'day')}',
    'During sleep ${s.duringSleep}',
    'Injuries ${s.injuries}',
    'Emergency care ${s.emergencyCare}',
  ];
  return pw.Text(
    parts.join('   ·   '),
    style: pw.TextStyle(color: _muted, fontSize: 7.5),
  );
}

pw.Widget _section(
  String title,
  ReportFonts fonts,
  pw.Widget child, {
  pw.Widget? trailing,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              title.toUpperCase(),
              style: pw.TextStyle(
                font: fonts.bold,
                fontSize: 7.5,
                letterSpacing: 0.8,
                color: _c(Brand.violetDeep),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 3, bottom: 6),
        height: 0.6,
        color: _line,
      ),
      child,
    ],
  );
}

pw.Widget _heatLegend() {
  pw.Widget swatch(int argb) => pw.Container(
    width: 7,
    height: 7,
    margin: const pw.EdgeInsets.only(left: 2),
    decoration: pw.BoxDecoration(
      color: _c(argb),
      borderRadius: pw.BorderRadius.circular(1.5),
    ),
  );
  return pw.Row(
    children: [
      pw.Text('0', style: pw.TextStyle(color: _muted, fontSize: 6.5)),
      for (final h in Brand.heat) swatch(h),
      pw.SizedBox(width: 2),
      pw.Text('3+ / day', style: pw.TextStyle(color: _muted, fontSize: 6.5)),
    ],
  );
}

List<DateTime> _monthsIn(DateRange r) {
  final months = <DateTime>[];
  var m = DateTime(r.start.year, r.start.month);
  final last = DateTime(r.lastDay.year, r.lastDay.month);
  while (!m.isAfter(last)) {
    months.add(m);
    m = DateTime(m.year, m.month + 1);
  }
  return months;
}

pw.Widget _heatMap(SeizureStats s, ReportFonts fonts, double width) {
  final months = _monthsIn(s.range);
  final perRow = months.length <= 3
      ? months.length
      : (months.length <= 8 ? 4 : 5);
  const monthGap = 10.0;
  final monthWidth = (width - monthGap * (perRow - 1)) / perRow;
  final cell = math.min(12.0, (monthWidth - 6 * 1.4) / 7);
  const cellGap = 1.4;

  pw.Widget month(DateTime m) {
    final first = DateTime(m.year, m.month);
    final daysInMonth = DateTime(m.year, m.month + 1, 0).day;
    final lead = first.weekday - DateTime.monday;
    final rows = ((lead + daysInMonth) / 7).ceil();
    return pw.SizedBox(
      width: monthWidth,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            DateFormat.yMMM().format(m),
            style: pw.TextStyle(font: fonts.medium, fontSize: 7.5),
          ),
          pw.SizedBox(height: 2),
          for (var r = 0; r < rows; r++)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: cellGap),
              child: pw.Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    () {
                      final dayNum = r * 7 + c - lead + 1;
                      final inMonth = dayNum >= 1 && dayNum <= daysInMonth;
                      final day = DateTime(m.year, m.month, dayNum);
                      final inRange = inMonth && s.range.contains(day);
                      final count = s.perDay[day] ?? 0;
                      return pw.Container(
                        width: cell,
                        height: cell,
                        margin: pw.EdgeInsets.only(right: c < 6 ? cellGap : 0),
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: inRange ? _c(Brand.heatFor(count)) : null,
                          border: inMonth && !inRange
                              ? pw.Border.all(color: _line, width: 0.4)
                              : null,
                          borderRadius: pw.BorderRadius.circular(1.8),
                        ),
                        child: count > 3
                            ? pw.Text(
                                '$count',
                                style: pw.TextStyle(
                                  font: fonts.bold,
                                  fontSize: 5.5,
                                  color: PdfColors.white,
                                ),
                              )
                            : null,
                      );
                    }(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  final rows = <pw.Widget>[];
  for (var i = 0; i < months.length; i += perRow) {
    final slice = months.sublist(i, math.min(i + perRow, months.length));
    rows.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (var j = 0; j < slice.length; j++) ...[
              if (j > 0) pw.SizedBox(width: monthGap),
              month(slice[j]),
            ],
          ],
        ),
      ),
    );
  }
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: rows,
  );
}

pw.Widget _empty(String text) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(vertical: 6),
  child: pw.Text(text, style: pw.TextStyle(color: _muted, fontSize: 8)),
);

pw.Widget _typeBars(SeizureStats s, ReportFonts fonts, double width) {
  if (s.byType.isEmpty) return _empty('No seizures recorded in this period.');
  final shown = s.byType.take(8).toList();
  final maxCount = shown.map((t) => t.count).reduce(math.max);
  final barMax = width - 32;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (final t in shown)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      t.type.label,
                      style: pw.TextStyle(font: fonts.medium, fontSize: 7.8),
                      maxLines: 1,
                    ),
                  ),
                  pw.Text(
                    t.medianDuration == null
                        ? ''
                        : 'median ${formatDurationShort(t.medianDuration)}',
                    style: pw.TextStyle(color: _muted, fontSize: 6.5),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                children: [
                  pw.Container(
                    width: math.max(3, barMax * t.count / maxCount),
                    height: 7,
                    decoration: pw.BoxDecoration(
                      color: _c(Brand.typeColor(t.type)),
                      borderRadius: pw.BorderRadius.circular(2),
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text(
                    '${t.count}',
                    style: pw.TextStyle(font: fonts.bold, fontSize: 8),
                  ),
                ],
              ),
            ],
          ),
        ),
      if (s.byType.length > shown.length)
        pw.Text(
          '+ ${s.byType.length - shown.length} more types',
          style: pw.TextStyle(color: _muted, fontSize: 7),
        ),
    ],
  );
}

String _changeText(MedicationChangeEntry c) {
  final dose = c.change.dose.isEmpty ? '' : ' ${c.change.dose}';
  final note = c.change.note.isEmpty ? '' : ' (${c.change.note})';
  return switch (c.change.kind) {
    MedicationChangeKind.started => 'Started ${c.medication.name}$dose$note',
    MedicationChangeKind.doseChanged =>
      '${c.medication.name} dose changed to$dose$note',
    MedicationChangeKind.stopped => 'Stopped ${c.medication.name}$note',
  };
}

pw.Widget _timeline(ReportData data, ReportFonts fonts, double width) {
  final s = data.stats;
  const chartHeight = 92.0;
  const axisWidth = 16.0;
  final plotWidth = width - axisWidth;
  final buckets = s.buckets;
  final peak = buckets.isEmpty
      ? 0
      : buckets.map((b) => b.count).reduce(math.max);
  // An even axis maximum keeps the half-way tick a whole number.
  final maxCount = math.max(2, peak.isOdd ? peak + 1 : peak);
  final firstDay = buckets.isEmpty ? s.range.start : buckets.first.start;
  final totalDays = buckets.length * s.bucketDays;
  double xFor(DateTime d) =>
      plotWidth * daysBetween(firstDay, d).clamp(0, totalDays) / totalDays;
  final slot = plotWidth / math.max(1, buckets.length);
  final barWidth = math.max(1.5, slot * 0.68);
  final changes = data.changesInRange;
  final shownChanges = changes.take(6).toList();

  final children = <pw.Widget>[
    // Grid lines at 0, half and max.
    for (final f in [0.0, 0.5, 1.0])
      pw.Positioned(
        left: axisWidth,
        bottom: chartHeight * f,
        child: pw.Container(
          width: plotWidth,
          height: f == 0 ? 0.8 : 0.4,
          color: f == 0 ? _muted : _line,
        ),
      ),
    for (final f in [0.5, 1.0])
      pw.Positioned(
        left: 0,
        bottom: chartHeight * f - 4,
        child: pw.Text(
          '${(maxCount * f).round()}',
          style: pw.TextStyle(color: _muted, fontSize: 6.5),
        ),
      ),
    for (var i = 0; i < buckets.length; i++)
      if (buckets[i].count > 0)
        pw.Positioned(
          left: axisWidth + slot * i + (slot - barWidth) / 2,
          bottom: 0.8,
          child: pw.Container(
            width: barWidth,
            height: chartHeight * buckets[i].count / maxCount,
            decoration: pw.BoxDecoration(
              color: _violet,
              borderRadius: const pw.BorderRadius.vertical(
                top: pw.Radius.circular(1.5),
              ),
            ),
          ),
        ),
    for (var i = 0; i < shownChanges.length; i++) ...[
      pw.Positioned(
        left: axisWidth + xFor(shownChanges[i].change.date),
        bottom: 0,
        child: pw.CustomPaint(
          size: const PdfPoint(1, chartHeight + 4),
          painter: (canvas, size) {
            canvas
              ..setStrokeColor(_c(Brand.amber))
              ..setLineWidth(0.9)
              ..setLineDashPattern([2, 1.5])
              ..moveTo(0.5, 0)
              ..lineTo(0.5, size.y)
              ..strokePath();
          },
        ),
      ),
      pw.Positioned(
        left: axisWidth + xFor(shownChanges[i].change.date) - 5,
        top: -6,
        child: _marker(i + 1, fonts),
      ),
    ],
  ];

  // Month labels along the x axis, skipping any that would overlap.
  final labels = <pw.Widget>[];
  var lastLabelX = double.negativeInfinity;
  for (final m in _monthsIn(s.range)) {
    final d = m.isBefore(s.range.start) ? s.range.start : m;
    final x = xFor(d);
    if (x - lastLabelX < 26) continue;
    lastLabelX = x;
    labels.add(
      pw.Positioned(
        left: axisWidth + x,
        top: 0,
        child: pw.Text(
          DateFormat.MMM().format(d),
          style: pw.TextStyle(color: _muted, fontSize: 6.5),
        ),
      ),
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 4),
      pw.SizedBox(
        width: width,
        height: chartHeight,
        child: pw.Stack(overflow: pw.Overflow.visible, children: children),
      ),
      pw.SizedBox(
        width: width,
        height: 11,
        child: pw.Stack(overflow: pw.Overflow.visible, children: labels),
      ),
      if (shownChanges.isEmpty)
        _empty('No medication changes in this period.')
      else
        pw.Wrap(
          spacing: 14,
          runSpacing: 3,
          children: [
            for (var i = 0; i < shownChanges.length; i++)
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  _marker(i + 1, fonts),
                  pw.SizedBox(width: 4),
                  pw.Text(
                    '${formatDayMonth(shownChanges[i].change.date)}  ',
                    style: pw.TextStyle(font: fonts.medium, fontSize: 7.5),
                  ),
                  pw.Text(
                    _changeText(shownChanges[i]),
                    style: const pw.TextStyle(fontSize: 7.5),
                  ),
                ],
              ),
            if (changes.length > shownChanges.length)
              pw.Text(
                '+ ${changes.length - shownChanges.length} more changes',
                style: pw.TextStyle(color: _muted, fontSize: 7.5),
              ),
          ],
        ),
    ],
  );
}

pw.Widget _marker(int n, ReportFonts fonts) => pw.Container(
  width: 10,
  height: 10,
  alignment: pw.Alignment.center,
  decoration: pw.BoxDecoration(
    color: _c(Brand.amber),
    shape: pw.BoxShape.circle,
  ),
  child: pw.Text(
    '$n',
    style: pw.TextStyle(font: fonts.bold, fontSize: 6, color: PdfColors.white),
  ),
);

pw.Widget _triggers(SeizureStats s) {
  if (s.byTrigger.isEmpty) return _empty('No triggers recorded.');
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (final t in s.byTrigger.take(6))
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2.5),
          child: pw.Row(
            children: [
              pw.Expanded(child: pw.Text(t.name, maxLines: 1)),
              pw.Text(
                '${t.count}  ',
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(
                width: 24,
                child: pw.Text(
                  '${(t.count / s.total * 100).round()}%',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(color: _muted, fontSize: 7),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

pw.Widget _sleep(SeizureStats s) {
  final sl = s.sleep;
  if (sl.nightsLogged == 0) return _empty('No sleep logged.');
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('Average ${formatHours(sl.averageHours!)} per night'),
      pw.Text(
        '${plural(sl.nightsLogged, 'night')} logged',
        style: pw.TextStyle(color: _muted, fontSize: 7.5),
      ),
      pw.SizedBox(height: 4),
      if (sl.seizuresWithSleepData > 0)
        pw.Text(
          '${sl.seizuresAfterShortSleep} of ${sl.seizuresWithSleepData} '
          'seizures followed a night under '
          '${SeizureStats.shortSleepHours.toInt()} h',
        ),
    ],
  );
}

pw.Widget _medications(ReportData data) {
  final active = data.medications.where((m) => m.active).toList()
    ..sort((a, b) {
      final k = a.kind.index.compareTo(b.kind.index);
      return k != 0 ? k : a.name.compareTo(b.name);
    });
  if (active.isEmpty) return _empty('No medications recorded.');
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (final m in active.take(7))
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2.5),
          child: pw.RichText(
            maxLines: 1,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: m.name,
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (m.dose.isNotEmpty) pw.TextSpan(text: '  ${m.dose}'),
                if (m.schedule.isNotEmpty)
                  pw.TextSpan(
                    text: '  ·  ${m.schedule}',
                    style: pw.TextStyle(color: _muted),
                  ),
                if (m.kind == MedicationKind.rescue)
                  pw.TextSpan(
                    text: '  rescue',
                    style: pw.TextStyle(color: _c(Brand.alert), fontSize: 7),
                  ),
              ],
            ),
          ),
        ),
    ],
  );
}

pw.Widget _footer(ReportData data) {
  return pw.Column(
    children: [
      pw.Container(height: 0.6, color: _line),
      pw.SizedBox(height: 4),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              'Recorded by the patient or a caregiver with Seizewell '
              '${data.appVersion}. Stored and generated on the device; '
              'not a diagnosis.',
              style: pw.TextStyle(color: _muted, fontSize: 6.5),
            ),
          ),
          pw.Text(
            'Page 1 of 1',
            style: pw.TextStyle(color: _muted, fontSize: 6.5),
          ),
        ],
      ),
    ],
  );
}
