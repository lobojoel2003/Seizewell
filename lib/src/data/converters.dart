import 'package:drift/drift.dart';

/// Stores calendar dates (no time, no time zone) as `YYYY-MM-DD` text so a
/// sleep log or a medication change never shifts to another day when the
/// phone changes time zone.
class DateOnlyConverter extends TypeConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromSql(String fromDb) {
    final parts = fromDb.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  @override
  String toSql(DateTime value) => formatIsoDate(value);
}

String formatIsoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Strips the time of day.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
