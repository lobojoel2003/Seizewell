import 'package:flutter_test/flutter_test.dart';
import 'package:seizewell/src/data/database.dart';
import 'package:seizewell/src/data/queries.dart';
import 'package:seizewell/src/domain/stats.dart';
import 'package:seizewell/src/domain/types.dart';

int _id = 0;

SeizureEntry entry(
  DateTime start, {
  int seconds = 60,
  SeizureType type = SeizureType.focalAware,
  List<String> triggers = const [],
  bool rescue = false,
  bool known = true,
  bool active = false,
}) {
  final id = ++_id;
  return SeizureEntry(
    Seizure(
      id: id,
      startedAt: start,
      endedAt: active ? null : start.add(Duration(seconds: seconds)),
      durationKnown: known,
      type: type,
      aura: false,
      duringSleep: false,
      injury: false,
      emergencyCare: false,
      rescueGivenAt: rescue ? start.add(const Duration(minutes: 5)) : null,
      rescueMedication: null,
      loggedBy: Reporter.patient,
      notes: '',
      detailsCompleted: true,
      createdAt: start,
      updatedAt: start,
    ),
    [
      for (var i = 0; i < triggers.length; i++)
        TriggerTag(
          id: triggers[i].hashCode,
          name: triggers[i],
          builtIn: true,
          archived: false,
          sortOrder: i,
        ),
    ],
  );
}

SleepLog night(DateTime d, double hours) =>
    SleepLog(id: d.day, night: d, hours: hours, quality: null, notes: '');

void main() {
  group('DateRange', () {
    test('lastDays includes today and has the right length', () {
      final r = DateRange.lastDays(30, DateTime(2026, 11, 18, 15));
      expect(r.start, DateTime(2026, 10, 20));
      expect(r.end, DateTime(2026, 11, 19));
      expect(r.lastDay, DateTime(2026, 11, 18));
      expect(r.days, 30);
      expect(r.eachDay.length, 30);
      expect(r.previous.end, r.start);
      expect(r.previous.days, 30);
    });

    test('day counting ignores daylight-saving changes', () {
      expect(daysBetween(DateTime(2026, 3, 1), DateTime(2026, 4, 1)), 31);
      expect(daysBetween(DateTime(2026, 10, 1), DateTime(2026, 11, 1)), 31);
    });
  });

  group('SeizureStats', () {
    final range = DateRange(DateTime(2026, 11, 1), DateTime(2026, 11, 15));

    test('counts, durations and streaks', () {
      final stats = SeizureStats.compute(
        range: range,
        seizures: [
          entry(DateTime(2026, 11, 2, 8), seconds: 30),
          entry(DateTime(2026, 11, 2, 20), seconds: 90),
          entry(DateTime(2026, 11, 10, 9), seconds: 400, rescue: true),
          entry(DateTime(2026, 11, 12, 9), known: false),
          entry(DateTime(2026, 10, 20)), // before range
          entry(DateTime(2026, 11, 14), active: true), // still running
        ],
      );
      expect(stats.total, 4);
      expect(stats.seizureDays, 3);
      expect(stats.perDay[DateTime(2026, 11, 2)], 2);
      expect(stats.longest, const Duration(seconds: 400));
      expect(stats.median, const Duration(seconds: 90));
      expect(stats.prolonged, 1);
      expect(stats.rescueDoses, 1);
      // Nov 3 – Nov 9 is the longest gap.
      expect(stats.longestSeizureFreeDays, 7);
      expect(stats.perThirtyDays, closeTo(4 / 14 * 30, 0.001));
    });

    test('groups by type and trigger, most common first', () {
      final stats = SeizureStats.compute(
        range: range,
        seizures: [
          entry(
            DateTime(2026, 11, 3),
            type: SeizureType.absence,
            triggers: ['Stress'],
          ),
          entry(
            DateTime(2026, 11, 4),
            type: SeizureType.absence,
            triggers: ['Stress', 'Lack of sleep'],
          ),
          entry(
            DateTime(2026, 11, 5),
            type: SeizureType.tonicClonic,
            seconds: 120,
          ),
        ],
      );
      expect(stats.byType.map((t) => t.type), [
        SeizureType.absence,
        SeizureType.tonicClonic,
      ]);
      expect(stats.byType.first.count, 2);
      expect(stats.byType.last.medianDuration, const Duration(minutes: 2));
      expect(stats.byTrigger.map((t) => '${t.name}:${t.count}'), [
        'Stress:2',
        'Lack of sleep:1',
      ]);
    });

    test('daily buckets for short ranges, Monday weeks for long ones', () {
      final short = SeizureStats.compute(range: range, seizures: const []);
      expect(short.bucketDays, 1);
      expect(short.buckets, hasLength(14));

      final long = SeizureStats.compute(
        range: DateRange.lastDays(90, DateTime(2026, 11, 18)),
        seizures: [entry(DateTime(2026, 11, 18, 7))],
      );
      expect(long.bucketDays, 7);
      expect(long.buckets.first.start.weekday, DateTime.monday);
      expect(long.buckets.last.count, 1);
      expect(long.buckets.fold<int>(0, (a, b) => a + b.count), 1);
    });

    test('compares with the previous period', () {
      final stats = SeizureStats.compute(
        range: range,
        seizures: [entry(DateTime(2026, 11, 3))],
        previousPeriod: [
          entry(DateTime(2026, 10, 20)),
          entry(DateTime(2026, 10, 25)),
        ],
      );
      expect(stats.previousTotal, 2);
      expect(stats.changeVsPrevious, -0.5);
    });

    test('links seizures to the night before', () {
      final stats = SeizureStats.compute(
        range: range,
        seizures: [
          entry(DateTime(2026, 11, 3, 10)),
          entry(DateTime(2026, 11, 4, 10)),
          entry(DateTime(2026, 11, 8, 10)),
        ],
        sleep: [
          night(DateTime(2026, 11, 3), 5),
          night(DateTime(2026, 11, 4), 8),
          night(DateTime(2026, 11, 5), 7),
        ],
      );
      expect(stats.sleep.nightsLogged, 3);
      expect(stats.sleep.averageHours, closeTo(20 / 3, 0.001));
      expect(stats.sleep.seizuresWithSleepData, 2);
      expect(stats.sleep.seizuresAfterShortSleep, 1);
    });
  });

  test('days since last seizure', () {
    expect(daysSinceLastSeizure(const [], DateTime(2026, 11, 18)), isNull);
    expect(
      daysSinceLastSeizure([
        entry(DateTime(2026, 11, 15, 23)),
        entry(DateTime(2026, 11, 1)),
      ], DateTime(2026, 11, 18, 1)),
      3,
    );
  });

  test('seizure type codes are stable kebab-case', () {
    expect(SeizureType.focalToBilateral.code, 'focal-to-bilateral');
    expect(SeizureType.tonicClonic.code, 'tonic-clonic');
    expect(SeizureType.fromCode('tonic-clonic'), SeizureType.tonicClonic);
    expect(SeizureType.fromCode('nonsense'), SeizureType.unknown);
  });
}
