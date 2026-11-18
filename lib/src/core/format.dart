import 'package:intl/intl.dart';

/// "45 s", "2 min 14 s", "1 h 05 min".
String formatDuration(Duration? d, {String unknown = 'Unknown'}) {
  if (d == null) return unknown;
  final total = d.inSeconds;
  if (total < 60) return '$total s';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = total.remainder(60);
  if (h > 0) return '$h h ${m.toString().padLeft(2, '0')} min';
  return s == 0 ? '$m min' : '$m min $s s';
}

/// Short form for charts and tiles: "45s", "2m 14s", "1h 5m".
String formatDurationShort(Duration? d, {String unknown = '—'}) {
  if (d == null) return unknown;
  final total = d.inSeconds;
  if (total < 60) return '${total}s';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = total.remainder(60);
  if (h > 0) return '${h}h ${m}m';
  return s == 0 ? '${m}m' : '${m}m ${s}s';
}

/// Stopwatch display: "04:59", "1:02:03".
String formatStopwatch(Duration d) {
  final neg = d.isNegative;
  final x = d.abs();
  final h = x.inHours;
  final m = x.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = x.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${neg ? '-' : ''}${h > 0 ? '$h:' : ''}$m:$s';
}

String formatDate(DateTime d) => DateFormat.yMMMd().format(d);
String formatDateLong(DateTime d) => DateFormat.yMMMMEEEEd().format(d);
String formatDayMonth(DateTime d) => DateFormat.MMMd().format(d);
String formatTime(DateTime d) => DateFormat.jm().format(d);
String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';
String formatMonthYear(DateTime d) => DateFormat.yMMMM().format(d);
String formatMonthShort(DateTime d) => DateFormat.MMM().format(d);

String formatRange(DateTime start, DateTime lastDay) {
  if (start.year == lastDay.year) {
    return '${DateFormat.MMMd().format(start)} – ${DateFormat.yMMMd().format(lastDay)}';
  }
  return '${formatDate(start)} – ${formatDate(lastDay)}';
}

/// "Today", "Yesterday", "3 days ago".
String formatDaysAgo(int days) {
  if (days <= 0) return 'Today';
  if (days == 1) return 'Yesterday';
  return '$days days ago';
}

String plural(int n, String one, [String? many]) =>
    '$n ${n == 1 ? one : (many ?? '${one}s')}';

/// "7.5 h", "8 h".
String formatHours(double h) {
  final rounded = (h * 10).round() / 10;
  return rounded == rounded.roundToDouble()
      ? '${rounded.toInt()} h'
      : '${rounded.toStringAsFixed(1)} h';
}

/// ISO 8601 with the local UTC offset, e.g. 2026-11-03T14:02:10+01:00.
String isoWithOffset(DateTime d) {
  final local = d.toLocal();
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final oh = offset.inHours.abs().toString().padLeft(2, '0');
  final om = offset.inMinutes.remainder(60).abs().toString().padLeft(2, '0');
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-'
      '${two(local.day)}T${two(local.hour)}:${two(local.minute)}:'
      '${two(local.second)}$sign$oh:$om';
}
