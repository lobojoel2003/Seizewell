import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:seizewell/src/core/format.dart';
import 'package:seizewell/src/data/connection.dart';
import 'package:seizewell/src/data/database.dart';
import 'package:seizewell/src/data/queries.dart';
import 'package:seizewell/src/domain/emergency_plan.dart';
import 'package:seizewell/src/domain/types.dart';
import 'package:seizewell/src/services/export/csv_export.dart';
import 'package:seizewell/src/services/export/fhir_export.dart';

void main() {
  late AppDatabase db;
  final start = DateTime(2026, 11, 3, 14, 2, 10);

  setUp(() async {
    db = openTestDatabase();
    final tags = await db.allTriggers();
    await db.saveSeizure(
      SeizuresCompanion.insert(
        startedAt: start,
        endedAt: Value(start.add(const Duration(seconds: 134))),
        type: const Value(SeizureType.focalImpaired),
        rescueGivenAt: Value(start.add(const Duration(minutes: 5))),
        rescueMedication: const Value('Midazolam'),
        notes: const Value('Said "hello", then stared.\nConfused, 10 min'),
      ),
      {tags.firstWhere((t) => t.name == 'Stress').id},
      now: start,
    );
    await db.saveSeizure(
      SeizuresCompanion.insert(
        startedAt: start.add(const Duration(days: 1)),
        endedAt: Value(start.add(const Duration(days: 1))),
        durationKnown: const Value(false),
        notes: const Value('=cmd|calc'),
      ),
      {},
      now: start,
    );
    await db.addMedication(
      name: 'Levetiracetam',
      kind: MedicationKind.maintenance,
      dose: '500 mg',
      startedOn: DateTime(2026, 1, 1),
    );
    await db.upsertSleep(night: DateTime(2026, 11, 3), hours: 6.5, quality: 3);
  });

  tearDown(() => db.close());

  group('CSV', () {
    test('quotes, escapes and guards against formulas', () {
      final csv = toCsv([
        ['a', 'b,c', 'say "hi"', 'line\nbreak', '=SUM(A1)', 3, null, true],
      ]);
      expect(csv, 'a,"b,c","say ""hi""","line\nbreak",\'=SUM(A1),3,,yes\r\n');
    });

    test('seizures export has a header and one row per seizure', () async {
      final csv = seizuresCsv(await db.allSeizures());
      final lines = const LineSplitter().convert(csv);
      expect(lines.first, startsWith('id,start,end,duration_seconds'));
      expect(csv, contains(',134,yes,focal-impaired,'));
      expect(csv, contains('Stress'));
      expect(csv, contains('"Said ""hello"", then stared.\nConfused, 10 min"'));
      expect(csv, contains("'=cmd|calc"));
    });

    test('medication and sleep exports', () async {
      final meds = medicationsCsv(
        await db.allMedications(),
        await db.allMedicationChanges(),
      );
      expect(
        meds,
        contains('2026-01-01,Levetiracetam,maintenance,started,500 mg'),
      );
      expect(sleepCsv(await db.allSleep()), contains('2026-11-03,6.5,3'));
    });
  });

  group('FHIR', () {
    late Map<String, Object?> bundle;

    setUp(() async {
      bundle = buildFhirBundle(
        seizures: await db.allSeizures(),
        sleep: await db.allSleep(),
        medications: await db.allMedications(),
        medicationChanges: await db.allMedicationChanges(),
        generatedAt: DateTime(2026, 11, 18, 9),
        patientName: 'Sam Taylor',
        birthDate: DateTime(2011, 4, 12),
        random: Random(3),
      );
    });

    List<Map<String, Object?>> resources(String type) => [
      for (final e in (bundle['entry']! as List).cast<Map<String, Object?>>())
        if ((e['resource']! as Map<String, Object?>)['resourceType'] == type)
          e['resource']! as Map<String, Object?>,
    ];

    String componentCode(Map<String, Object?> c) {
      final code = c['code']! as Map<String, Object?>;
      final coding = (code['coding']! as List).first as Map<String, Object?>;
      return coding['code']! as String;
    }

    test('is a collection bundle that round-trips through JSON', () {
      final decoded = jsonDecode(encodeFhirBundle(bundle)) as Map;
      expect(decoded['resourceType'], 'Bundle');
      expect(decoded['type'], 'collection');
      for (final e in decoded['entry'] as List) {
        expect((e as Map)['fullUrl'], startsWith('urn:uuid:'));
      }
    });

    test('patient resource', () {
      final p = resources('Patient').single;
      expect(p['name'], [
        {'text': 'Sam Taylor'},
      ]);
      expect(p['birthDate'], '2011-04-12');
    });

    test('seizures are SNOMED-coded observations', () {
      final obs = resources('Observation')
          .where((o) => (o['id'] as String).startsWith('seizure-'))
          .toList();
      expect(obs, hasLength(2));
      final first = obs.first;
      final coding = ((first['code'] as Map)['coding'] as List).single as Map;
      expect(coding['system'], 'http://snomed.info/sct');
      expect(coding['code'], '91175000');
      expect(first['status'], 'final');
      expect((first['effectivePeriod'] as Map)['start'], isoWithOffset(start));
      final value = first['valueCodeableConcept'] as Map;
      expect(
        ((value['coding'] as List).single as Map)['code'],
        'focal-impaired',
      );
      final components = (first['component']! as List)
          .cast<Map<String, Object?>>();
      final duration = components.firstWhere(
        (c) => componentCode(c) == 'duration',
      );
      expect(duration['valueQuantity'], {
        'value': 134,
        'unit': 's',
        'system': 'http://unitsofmeasure.org',
        'code': 's',
      });
      expect(
        components.where((c) => componentCode(c) == 'trigger'),
        hasLength(1),
      );

      // Unknown duration: no end, no duration component.
      final second = obs.last;
      expect((second['effectivePeriod'] as Map).containsKey('end'), isFalse);
    });

    test('sleep uses LOINC 93832-4 in hours', () {
      final sleep = resources('Observation')
          .firstWhere((o) => (o['id'] as String).startsWith('sleep-'));
      final coding = ((sleep['code'] as Map)['coding'] as List).single as Map;
      expect(coding['system'], 'http://loinc.org');
      expect(coding['code'], '93832-4');
      expect((sleep['valueQuantity'] as Map)['value'], 6.5);
      expect(sleep['effectiveDateTime'], '2026-11-03');
    });

    test('medication statements', () {
      final m = resources('MedicationStatement').single;
      expect(m['status'], 'active');
      expect((m['medicationCodeableConcept'] as Map)['text'], 'Levetiracetam');
      expect((m['effectivePeriod'] as Map)['start'], '2026-01-01');
    });

    test('uuid v4 format', () {
      expect(
        uuidV4(Random(1)),
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });
  });

  group('format', () {
    test('durations', () {
      expect(formatDuration(const Duration(seconds: 45)), '45 s');
      expect(formatDuration(const Duration(seconds: 134)), '2 min 14 s');
      expect(formatDuration(const Duration(minutes: 5)), '5 min');
      expect(formatDuration(const Duration(minutes: 65)), '1 h 05 min');
      expect(formatDuration(null), 'Unknown');
      expect(formatDurationShort(const Duration(seconds: 134)), '2m 14s');
      expect(formatStopwatch(const Duration(seconds: 299)), '04:59');
      expect(formatStopwatch(const Duration(hours: 1, seconds: 3)), '1:00:03');
      expect(formatHours(7.5), '7.5 h');
      expect(formatHours(8), '8 h');
      expect(formatDaysAgo(0), 'Today');
      expect(formatDaysAgo(1), 'Yesterday');
      expect(formatDaysAgo(4), '4 days ago');
    });
  });

  group('emergency plan', () {
    test('round-trips through JSON and tolerates bad input', () {
      const plan = EmergencyPlan(
        alertAfter: Duration(minutes: 3),
        rescueMedication: 'Diazepam',
        minHoursBetweenRescueDoses: 12,
        contacts: [EmergencyContact(name: 'A', phone: '1')],
        instructions: 'Steps',
      );
      final back = EmergencyPlan.decode(plan.encode());
      expect(back.alertAfter, const Duration(minutes: 3));
      expect(back.rescueMedication, 'Diazepam');
      expect(back.minHoursBetweenRescueDoses, 12);
      expect(
        back.contacts.single,
        const EmergencyContact(name: 'A', phone: '1'),
      );
      expect(
        EmergencyPlan.decode('{not json').alertAfter,
        const Duration(minutes: 5),
      );
    });

    test('regional emergency numbers', () {
      expect(EmergencyPlan.defaultEmergencyNumber('US'), '911');
      expect(EmergencyPlan.defaultEmergencyNumber('gb'), '999');
      expect(EmergencyPlan.defaultEmergencyNumber('AU'), '000');
      expect(EmergencyPlan.defaultEmergencyNumber('DE'), '112');
      expect(EmergencyPlan.defaultEmergencyNumber(null), '112');
    });
  });
}
