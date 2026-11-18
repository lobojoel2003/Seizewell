import 'dart:math' as math;

import '../data/database.dart';
import '../data/queries.dart';
import 'types.dart';

/// A span of whole calendar days, `[start, end)`.
class DateRange {
  DateRange(DateTime start, DateTime end)
    : start = dateOnly(start),
      end = dateOnly(end) {
    if (!this.end.isAfter(this.start)) {
      throw ArgumentError('DateRange end must be after start');
    }
  }

  /// The last [days] days, including [today].
  factory DateRange.lastDays(int days, DateTime today) {
    final t = dateOnly(today);
    return DateRange(
      DateTime(t.year, t.month, t.day - (days - 1)),
      DateTime(t.year, t.month, t.day + 1),
    );
  }

  final DateTime start;
  final DateTime end;

  int get days => daysBetween(start, end);

  /// The last day included in the range.
  DateTime get lastDay => DateTime(end.year, end.month, end.day - 1);

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);

  /// The range of the same length immediately before this one.
  DateRange get previous =>
      DateRange(DateTime(start.year, start.month, start.day - days), start);

  Iterable<DateTime> get eachDay sync* {
    for (var i = 0; i < days; i++) {
      yield DateTime(start.year, start.month, start.day + i);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// Whole days between two dates, safe across daylight-saving changes.
int daysBetween(DateTime a, DateTime b) => DateTime.utc(
  b.year,
  b.month,
  b.day,
).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

class TypeCount {
  const TypeCount(this.type, this.count, this.medianDuration);
  final SeizureType type;
  final int count;
  final Duration? medianDuration;
}

class NamedCount {
  const NamedCount(this.name, this.count);
  final String name;
  final int count;
}

class Bucket {
  const Bucket(this.start, this.count);
  final DateTime start;
  final int count;
}

class SleepSummary {
  const SleepSummary({
    required this.nightsLogged,
    required this.averageHours,
    required this.seizuresWithSleepData,
    required this.seizuresAfterShortSleep,
  });

  final int nightsLogged;
  final double? averageHours;

  /// Seizures for which the previous night's sleep was logged.
  final int seizuresWithSleepData;

  /// Of those, how many followed a night shorter than
  /// [SeizureStats.shortSleepHours].
  final int seizuresAfterShortSleep;
}

/// Everything the Insights screen and the clinic report show.
class SeizureStats {
  const SeizureStats({
    required this.range,
    required this.total,
    required this.seizureDays,
    required this.perThirtyDays,
    required this.longest,
    required this.median,
    required this.prolonged,
    required this.rescueDoses,
    required this.emergencyCare,
    required this.injuries,
    required this.duringSleep,
    required this.longestSeizureFreeDays,
    required this.perDay,
    required this.byType,
    required this.byTrigger,
    required this.buckets,
    required this.bucketDays,
    required this.previousTotal,
    required this.sleep,
    required this.prolongedThreshold,
  });

  static const shortSleepHours = 6.0;

  final DateRange range;
  final int total;
  final int seizureDays;
  final double perThirtyDays;
  final Duration? longest;
  final Duration? median;

  /// Seizures that lasted at least [prolongedThreshold].
  final int prolonged;
  final Duration prolongedThreshold;
  final int rescueDoses;
  final int emergencyCare;
  final int injuries;
  final int duringSleep;
  final int longestSeizureFreeDays;
  final Map<DateTime, int> perDay;
  final List<TypeCount> byType;
  final List<NamedCount> byTrigger;

  /// Seizure counts per day (short ranges) or per week (longer ranges).
  final List<Bucket> buckets;
  final int bucketDays;

  /// Total in the preceding period of equal length, when known.
  final int? previousTotal;
  final SleepSummary sleep;

  bool get isEmpty => total == 0;

  /// Relative change against the previous period, e.g. -0.25 for 25% fewer.
  double? get changeVsPrevious {
    final prev = previousTotal;
    if (prev == null || prev == 0) return null;
    return (total - prev) / prev;
  }

  static SeizureStats compute({
    required DateRange range,
    required List<SeizureEntry> seizures,
    List<SeizureEntry>? previousPeriod,
    List<SleepLog> sleep = const [],
    Duration prolongedThreshold = const Duration(minutes: 5),
  }) {
    final inRange =
        seizures
            .where((s) => !s.isActive && range.contains(s.startedAt))
            .toList()
          ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    final perDay = <DateTime, int>{};
    for (final s in inRange) {
      perDay.update(dateOnly(s.startedAt), (v) => v + 1, ifAbsent: () => 1);
    }

    final durations = [
      for (final s in inRange)
        if (s.duration != null) s.duration!,
    ];

    // Seizure-free streaks, counted in whole days inside the range.
    var longestFree = 0;
    var run = 0;
    for (final day in range.eachDay) {
      if (perDay.containsKey(day)) {
        run = 0;
      } else {
        run++;
        longestFree = math.max(longestFree, run);
      }
    }

    final byTypeMap = <SeizureType, List<SeizureEntry>>{};
    for (final s in inRange) {
      byTypeMap.putIfAbsent(s.seizure.type, () => []).add(s);
    }
    final byType =
        [
          for (final e in byTypeMap.entries)
            TypeCount(
              e.key,
              e.value.length,
              _median([
                for (final s in e.value)
                  if (s.duration != null) s.duration!,
              ]),
            ),
        ]..sort((a, b) {
          final c = b.count.compareTo(a.count);
          return c != 0 ? c : a.type.index.compareTo(b.type.index);
        });

    final triggerMap = <String, int>{};
    for (final s in inRange) {
      for (final t in s.triggers) {
        triggerMap.update(t.name, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    final byTrigger =
        [for (final e in triggerMap.entries) NamedCount(e.key, e.value)]
          ..sort((a, b) {
            final c = b.count.compareTo(a.count);
            return c != 0 ? c : a.name.compareTo(b.name);
          });

    final bucketDays = range.days <= 31 ? 1 : 7;
    final buckets = _buckets(range, perDay, bucketDays);

    final sleepInRange = sleep.where((l) => range.contains(l.night)).toList();
    final sleepByNight = {for (final l in sleep) dateOnly(l.night): l};
    var withSleep = 0;
    var afterShort = 0;
    for (final s in inRange) {
      final night = sleepByNight[dateOnly(s.startedAt)];
      if (night == null) continue;
      withSleep++;
      if (night.hours < shortSleepHours) afterShort++;
    }

    return SeizureStats(
      range: range,
      total: inRange.length,
      seizureDays: perDay.length,
      perThirtyDays: inRange.length / range.days * 30,
      longest: durations.isEmpty ? null : durations.reduce(_max),
      median: _median(durations),
      prolonged: durations.where((d) => d >= prolongedThreshold).length,
      prolongedThreshold: prolongedThreshold,
      rescueDoses: inRange.where((s) => s.seizure.rescueGivenAt != null).length,
      emergencyCare: inRange.where((s) => s.seizure.emergencyCare).length,
      injuries: inRange.where((s) => s.seizure.injury).length,
      duringSleep: inRange.where((s) => s.seizure.duringSleep).length,
      longestSeizureFreeDays: longestFree,
      perDay: perDay,
      byType: byType,
      byTrigger: byTrigger,
      buckets: buckets,
      bucketDays: bucketDays,
      previousTotal: previousPeriod
          ?.where((s) => !s.isActive && range.previous.contains(s.startedAt))
          .length,
      sleep: SleepSummary(
        nightsLogged: sleepInRange.length,
        averageHours: sleepInRange.isEmpty
            ? null
            : sleepInRange.map((l) => l.hours).reduce((a, b) => a + b) /
                  sleepInRange.length,
        seizuresWithSleepData: withSleep,
        seizuresAfterShortSleep: afterShort,
      ),
    );
  }

  static Duration _max(Duration a, Duration b) => a >= b ? a : b;

  static Duration? _median(List<Duration> values) {
    if (values.isEmpty) return null;
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return Duration(
      microseconds:
          (sorted[mid - 1].inMicroseconds + sorted[mid].inMicroseconds) ~/ 2,
    );
  }

  static List<Bucket> _buckets(
    DateRange range,
    Map<DateTime, int> perDay,
    int size,
  ) {
    var cursor = range.start;
    if (size == 7) {
      // Weeks start on Monday.
      cursor = DateTime(
        cursor.year,
        cursor.month,
        cursor.day - (cursor.weekday - DateTime.monday),
      );
    }
    final result = <Bucket>[];
    while (cursor.isBefore(range.end)) {
      var count = 0;
      for (var i = 0; i < size; i++) {
        count +=
            perDay[DateTime(cursor.year, cursor.month, cursor.day + i)] ?? 0;
      }
      result.add(Bucket(cursor, count));
      cursor = DateTime(cursor.year, cursor.month, cursor.day + size);
    }
    return result;
  }
}

/// Days since the most recent seizure, or `null` if none was logged.
int? daysSinceLastSeizure(List<SeizureEntry> seizures, DateTime today) {
  final finished = seizures.where((s) => !s.isActive);
  if (finished.isEmpty) return null;
  final last = finished
      .map((s) => s.startedAt)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  return math.max(0, daysBetween(last, today));
}
