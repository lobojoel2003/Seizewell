import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';

/// RFC 4180 CSV writer. Fields that could be interpreted as formulas by
/// spreadsheet apps are prefixed with an apostrophe (CSV injection guard).
String toCsv(List<List<Object?>> rows) {
  final buffer = StringBuffer();
  for (final row in rows) {
    buffer.write(row.map(_field).join(','));
    buffer.write('\r\n');
  }
  return buffer.toString();
}

String _field(Object? value) {
  var text = switch (value) {
    null => '',
    bool b => b ? 'yes' : 'no',
    DateTime d => isoWithOffset(d),
    _ => value.toString(),
  };
  if (text.isNotEmpty && '=+-@\t\r'.contains(text[0]) && value is String) {
    text = "'$text";
  }
  final needsQuotes =
      text.contains(',') ||
      text.contains('"') ||
      text.contains('\n') ||
      text.contains('\r');
  return needsQuotes ? '"${text.replaceAll('"', '""')}"' : text;
}

String seizuresCsv(List<SeizureEntry> entries) {
  final sorted = [...entries]
    ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  return toCsv([
    [
      'id',
      'start',
      'end',
      'duration_seconds',
      'duration_known',
      'type_code',
      'type',
      'triggers',
      'aura',
      'during_sleep',
      'injury',
      'emergency_care',
      'rescue_given_at',
      'rescue_medication',
      'logged_by',
      'notes',
    ],
    for (final e in sorted)
      [
        e.id,
        e.seizure.startedAt,
        e.seizure.endedAt,
        e.duration?.inSeconds,
        e.seizure.durationKnown,
        e.seizure.type.code,
        e.seizure.type.label,
        e.triggers.map((t) => t.name).join('; '),
        e.seizure.aura,
        e.seizure.duringSleep,
        e.seizure.injury,
        e.seizure.emergencyCare,
        e.seizure.rescueGivenAt,
        e.seizure.rescueMedication,
        e.seizure.loggedBy.name,
        e.seizure.notes,
      ],
  ]);
}

String medicationsCsv(
  List<Medication> meds,
  List<MedicationChangeEntry> changes,
) {
  final sorted = [...changes]
    ..sort((a, b) {
      final c = a.change.date.compareTo(b.change.date);
      return c != 0 ? c : a.change.id.compareTo(b.change.id);
    });
  return toCsv([
    ['date', 'medication', 'kind', 'change', 'dose', 'note'],
    for (final c in sorted)
      [
        formatIsoDate(c.change.date),
        c.medication.name,
        c.medication.kind.name,
        c.change.kind.name,
        c.change.dose,
        c.change.note,
      ],
  ]);
}

String sleepCsv(List<SleepLog> logs) {
  final sorted = [...logs]..sort((a, b) => a.night.compareTo(b.night));
  return toCsv([
    ['night_ending', 'hours', 'quality_1_to_5', 'notes'],
    for (final l in sorted)
      [formatIsoDate(l.night), l.hours, l.quality, l.notes],
  ]);
}
