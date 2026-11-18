import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:seizewell/src/data/connection.dart';
import 'package:seizewell/src/data/database.dart';
import 'package:seizewell/src/data/queries.dart';
import 'package:seizewell/src/data/settings_store.dart';
import 'package:seizewell/src/domain/emergency_plan.dart';
import 'package:seizewell/src/domain/types.dart';

void main() {
  late AppDatabase db;
  final t0 = DateTime(2026, 11, 3, 14, 2, 10);

  setUp(() => db = openTestDatabase());
  tearDown(() => db.close());

  group('seizure timer', () {
    test('start, end and duration', () async {
      final s = (await db.startSeizure(
        at: t0,
        loggedBy: Reporter.caregiver,
      )).seizure;
      expect((await db.activeSeizure())?.id, s.id);

      await db.endSeizure(
        s.id,
        t0.add(const Duration(minutes: 2, seconds: 14)),
      );
      expect(await db.activeSeizure(), isNull);

      final entry = (await db.seizureEntry(s.id))!;
      expect(entry.duration, const Duration(minutes: 2, seconds: 14));
      expect(entry.seizure.loggedBy, Reporter.caregiver);
      expect(entry.seizure.detailsCompleted, isFalse);
    });

    test('a second start while timing returns the running seizure', () async {
      final a = (await db.startSeizure(
        at: t0,
        loggedBy: Reporter.patient,
      )).seizure;
      final b = (await db.startSeizure(
        at: t0.add(const Duration(seconds: 1)),
        loggedBy: Reporter.patient,
      )).seizure;
      expect(b.id, a.id);
      expect(await db.select(db.seizures).get(), hasLength(1));
      final again = await db.startSeizure(at: t0, loggedBy: Reporter.patient);
      expect(again.created, isFalse);
    });

    test('a second "ended" never moves the end time', () async {
      final s = (await db.startSeizure(
        at: t0,
        loggedBy: Reporter.patient,
      )).seizure;
      expect(
        await db.endSeizure(s.id, t0.add(const Duration(seconds: 40))),
        isTrue,
      );
      expect(
        await db.endSeizure(s.id, t0.add(const Duration(minutes: 3))),
        isFalse,
      );
      expect(
        (await db.seizureEntry(s.id))!.duration,
        const Duration(seconds: 40),
      );
    });

    test('end before start is clamped to zero length', () async {
      final s = (await db.startSeizure(
        at: t0,
        loggedBy: Reporter.patient,
      )).seizure;
      await db.endSeizure(s.id, t0.subtract(const Duration(minutes: 1)));
      expect((await db.seizureEntry(s.id))!.duration, Duration.zero);
    });

    test('resume undoes an early end', () async {
      final s = (await db.startSeizure(
        at: t0,
        loggedBy: Reporter.patient,
      )).seizure;
      await db.endSeizure(s.id, t0.add(const Duration(seconds: 20)));
      await db.resumeSeizure(s.id);
      expect((await db.activeSeizure())?.id, s.id);
    });

    test('rescue medication is recorded', () async {
      final s = (await db.startSeizure(
        at: t0,
        loggedBy: Reporter.patient,
      )).seizure;
      final given = t0.add(const Duration(minutes: 5));
      await db.recordRescue(s.id, given, 'Midazolam nasal spray');
      final row = await db.seizureById(s.id);
      expect(row.rescueGivenAt, given);
      expect(row.rescueMedication, 'Midazolam nasal spray');
      expect(await db.watchLastRescueDose().first, given);
    });
  });

  group('saving details', () {
    test('saves fields and replaces triggers', () async {
      final tags = await db.watchTriggers().first;
      final stress = tags.firstWhere((t) => t.name == 'Stress');
      final sleep = tags.firstWhere((t) => t.name == 'Lack of sleep');

      final id = await db.saveSeizure(
        SeizuresCompanion.insert(
          startedAt: t0,
          endedAt: Value(t0.add(const Duration(seconds: 45))),
          type: const Value(SeizureType.focalImpaired),
          notes: const Value('Lip smacking, then confused for 10 min'),
          detailsCompleted: const Value(true),
        ),
        {stress.id, sleep.id},
        now: t0,
      );
      var entry = (await db.seizureEntry(id))!;
      expect(entry.seizure.type, SeizureType.focalImpaired);
      expect(entry.triggers.map((t) => t.name), ['Lack of sleep', 'Stress']);

      await db.saveSeizure(entry.seizure.toCompanion(true), {
        stress.id,
      }, now: t0);
      entry = (await db.seizureEntry(id))!;
      expect(entry.triggers.map((t) => t.name), ['Stress']);
    });

    test('entries needing details are listed until completed', () async {
      final s = (await db.startSeizure(
        at: t0,
        loggedBy: Reporter.patient,
      )).seizure;
      await db.endSeizure(s.id, t0.add(const Duration(seconds: 30)));
      expect(await db.watchNeedingDetails().first, hasLength(1));

      final row = await db.seizureById(s.id);
      await db.saveSeizure(
        row.copyWith(detailsCompleted: true).toCompanion(true),
        {},
        now: t0,
      );
      expect(await db.watchNeedingDetails().first, isEmpty);
    });

    test('range query is half-open and newest first', () async {
      for (var d = 1; d <= 5; d++) {
        await db.saveSeizure(
          SeizuresCompanion.insert(
            startedAt: DateTime(2026, 11, d, 9),
            endedAt: Value(DateTime(2026, 11, d, 9, 1)),
          ),
          {},
          now: t0,
        );
      }
      final list = await db.seizuresBetween(
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 4),
      );
      expect(list.map((e) => e.startedAt.day), [3, 2]);
    });
  });

  group('triggers', () {
    test('custom triggers are de-duplicated ignoring case', () async {
      final a = await db.addTrigger('Video games');
      final b = await db.addTrigger('  video GAMES ');
      expect(b.id, a.id);
    });

    test('archived triggers are hidden and come back when re-added', () async {
      final a = await db.addTrigger('Caffeine');
      await db.setTriggerArchived(a.id, true);
      expect(
        (await db.watchTriggers().first).map((t) => t.name),
        isNot(contains('Caffeine')),
      );
      await db.addTrigger('caffeine');
      expect(
        (await db.watchTriggers().first).map((t) => t.name),
        contains('Caffeine'),
      );
    });
  });

  group('medications', () {
    test('start, dose change and stop are recorded on the timeline', () async {
      final id = await db.addMedication(
        name: 'Levetiracetam',
        kind: MedicationKind.maintenance,
        dose: '500 mg',
        schedule: 'Twice daily',
        startedOn: DateTime(2026, 6, 1),
      );
      final med = await db.medicationById(id);
      await db.updateMedication(
        med.copyWith(dose: '750 mg'),
        changedOn: DateTime(2026, 9, 15),
      );
      await db.stopMedication(id, DateTime(2026, 11, 1));

      final changes = await db.allMedicationChanges();
      expect(changes.map((c) => c.change.kind), [
        MedicationChangeKind.stopped,
        MedicationChangeKind.doseChanged,
        MedicationChangeKind.started,
      ]);
      expect(changes[1].change.dose, '750 mg');
      expect(changes[1].change.note, 'was 500 mg');
      expect(changes[1].change.date, DateTime(2026, 9, 15));
      expect((await db.medicationById(id)).active, isFalse);
    });

    test('editing without a dose change records nothing new', () async {
      final id = await db.addMedication(
        name: 'Lamotrigine',
        kind: MedicationKind.maintenance,
        dose: '100 mg',
        startedOn: DateTime(2026, 1, 1),
      );
      final med = await db.medicationById(id);
      await db.updateMedication(
        med.copyWith(schedule: 'Morning'),
        changedOn: DateTime(2026, 2, 1),
      );
      expect(await db.allMedicationChanges(), hasLength(1));
    });
  });

  group('sleep', () {
    test('one log per night, updated in place', () async {
      final night = DateTime(2026, 11, 3, 7, 30);
      await db.upsertSleep(night: night, hours: 6.5, quality: 3);
      await db.upsertSleep(night: night, hours: 8, quality: 4);
      final all = await db.allSleep();
      expect(all, hasLength(1));
      expect(all.single.hours, 8);
      expect(all.single.night, DateTime(2026, 11, 3));
    });
  });

  group('settings store', () {
    test('persists profile and emergency plan', () async {
      var store = await SettingsStore.load(db, countryCode: 'GB');
      expect(store.plan.emergencyNumber, '999');
      expect(store.paperSize, PaperSize.a4);

      await store.setPatientName('  Maya  ');
      await store.setPlan(
        store.plan.copyWith(
          rescueMedication: 'Buccal midazolam',
          rescueDose: '10 mg',
          contacts: const [
            EmergencyContact(name: 'Dad', phone: '+44 7700 900123'),
          ],
        ),
      );

      store = await SettingsStore.load(db, countryCode: 'GB');
      expect(store.patientName, 'Maya');
      expect(store.plan.rescueMedication, 'Buccal midazolam');
      expect(store.plan.contacts.single.name, 'Dad');
    });

    test('delete everything clears data and re-seeds triggers', () async {
      (await db.startSeizure(at: t0, loggedBy: Reporter.patient)).seizure;
      await db.writeSetting('profile.name', 'Sam');
      await db.deleteEverything();
      expect(await db.select(db.seizures).get(), isEmpty);
      expect(await db.readAllSettings(), isEmpty);
      expect(await db.watchTriggers().first, hasLength(builtInTriggers.length));
    });
  });
}
