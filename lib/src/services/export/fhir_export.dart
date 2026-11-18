import 'dart:convert';
import 'dart:math';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../../domain/types.dart';

/// Base URL for Seizewell's own FHIR code systems. Documented in
/// `docs/fhir.md`.
const fhirCodeSystemBase =
    'https://github.com/lobojoel2003/Seizewell/fhir/CodeSystem';
const seizureTypeSystem = '$fhirCodeSystemBase/seizure-type';
const componentSystem = '$fhirCodeSystemBase/observation-component';
const snomed = 'http://snomed.info/sct';
const loinc = 'http://loinc.org';
const ucum = 'http://unitsofmeasure.org';

/// SNOMED CT 91175000 |Seizure (finding)|.
const seizureCode = '91175000';

/// LOINC 93832-4 "Sleep duration".
const sleepDurationCode = '93832-4';

String uuidV4([Random? random]) {
  final rng = random ?? Random.secure();
  final b = List<int>.generate(16, (_) => rng.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}

/// Builds a FHIR R4 `collection` Bundle with one Patient, one Observation per
/// seizure (SNOMED CT 91175000) and per night of sleep (LOINC 93832-4), and
/// one MedicationStatement per medication.
Map<String, Object?> buildFhirBundle({
  required List<SeizureEntry> seizures,
  required List<SleepLog> sleep,
  required List<Medication> medications,
  required List<MedicationChangeEntry> medicationChanges,
  required DateTime generatedAt,
  String patientName = '',
  DateTime? birthDate,
  Random? random,
}) {
  final patientUrl = 'urn:uuid:${uuidV4(random)}';
  final subject = {'reference': patientUrl};
  final entries = <Map<String, Object?>>[
    {
      'fullUrl': patientUrl,
      'resource': {
        'resourceType': 'Patient',
        'id': 'patient',
        if (patientName.trim().isNotEmpty)
          'name': [
            {'text': patientName.trim()},
          ],
        if (birthDate != null) 'birthDate': formatIsoDate(birthDate),
      },
    },
  ];

  Map<String, Object?> coding(String system, String code, String display) => {
    'coding': [
      {'system': system, 'code': code, 'display': display},
    ],
    'text': display,
  };

  Map<String, Object?> component(
    String code,
    String display,
    String key,
    Object value,
  ) => {'code': coding(componentSystem, code, display), key: value};

  final finished = seizures.where((s) => !s.isActive).toList()
    ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  for (final e in finished) {
    final s = e.seizure;
    entries.add({
      'fullUrl': 'urn:uuid:${uuidV4(random)}',
      'resource': {
        'resourceType': 'Observation',
        'id': 'seizure-${s.id}',
        'status': 'final',
        'code': coding(snomed, seizureCode, 'Seizure'),
        'subject': subject,
        'effectivePeriod': {
          'start': isoWithOffset(s.startedAt),
          if (s.durationKnown && s.endedAt != null)
            'end': isoWithOffset(s.endedAt!),
        },
        'issued': isoWithOffset(s.updatedAt),
        'performer': [
          {'display': s.loggedBy.label},
        ],
        'valueCodeableConcept': coding(
          seizureTypeSystem,
          s.type.code,
          s.type.label,
        ),
        'component': [
          if (e.duration != null)
            component('duration', 'Seizure duration', 'valueQuantity', {
              'value': e.duration!.inSeconds,
              'unit': 's',
              'system': ucum,
              'code': 's',
            }),
          component(
            'duration-known',
            'Duration was witnessed',
            'valueBoolean',
            s.durationKnown,
          ),
          for (final t in e.triggers)
            component('trigger', 'Suspected trigger', 'valueString', t.name),
          component('aura', 'Warning or aura', 'valueBoolean', s.aura),
          component(
            'during-sleep',
            'Occurred during sleep',
            'valueBoolean',
            s.duringSleep,
          ),
          component('injury', 'Injury', 'valueBoolean', s.injury),
          component(
            'emergency-care',
            'Emergency services or hospital',
            'valueBoolean',
            s.emergencyCare,
          ),
          if (s.rescueGivenAt != null) ...[
            component(
              'rescue-medication-time',
              'Rescue medication given',
              'valueDateTime',
              isoWithOffset(s.rescueGivenAt!),
            ),
            if ((s.rescueMedication ?? '').isNotEmpty)
              component(
                'rescue-medication',
                'Rescue medication',
                'valueString',
                s.rescueMedication!,
              ),
          ],
        ],
        if (s.notes.trim().isNotEmpty)
          'note': [
            {'text': s.notes.trim()},
          ],
      },
    });
  }

  final nights = [...sleep]..sort((a, b) => a.night.compareTo(b.night));
  for (final l in nights) {
    entries.add({
      'fullUrl': 'urn:uuid:${uuidV4(random)}',
      'resource': {
        'resourceType': 'Observation',
        'id': 'sleep-${l.id}',
        'status': 'final',
        'code': coding(loinc, sleepDurationCode, 'Sleep duration'),
        'subject': subject,
        'effectiveDateTime': formatIsoDate(l.night),
        'valueQuantity': {
          'value': l.hours,
          'unit': 'h',
          'system': ucum,
          'code': 'h',
        },
        if (l.quality != null)
          'component': [
            component(
              'sleep-quality',
              'Sleep quality (1–5)',
              'valueInteger',
              l.quality!,
            ),
          ],
        if (l.notes.trim().isNotEmpty)
          'note': [
            {'text': l.notes.trim()},
          ],
      },
    });
  }

  for (final m in medications) {
    final history =
        medicationChanges
            .where((c) => c.medication.id == m.id)
            .map((c) => c.change)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    final started = history
        .where((c) => c.kind == MedicationChangeKind.started)
        .map((c) => c.date)
        .firstOrNull;
    final stopped = m.active
        ? null
        : history
              .where((c) => c.kind == MedicationChangeKind.stopped)
              .map((c) => c.date)
              .lastOrNull;
    final dosage = [m.dose, m.schedule].where((x) => x.isNotEmpty).join(', ');
    entries.add({
      'fullUrl': 'urn:uuid:${uuidV4(random)}',
      'resource': {
        'resourceType': 'MedicationStatement',
        'id': 'medication-${m.id}',
        'status': m.active ? 'active' : 'stopped',
        'category': {
          'text': m.kind == MedicationKind.rescue
              ? 'Rescue medication'
              : 'Daily medication',
        },
        'medicationCodeableConcept': {'text': m.name},
        'subject': subject,
        if (started != null || stopped != null)
          'effectivePeriod': {
            if (started != null) 'start': formatIsoDate(started),
            if (stopped != null) 'end': formatIsoDate(stopped),
          },
        if (dosage.isNotEmpty)
          'dosage': [
            {'text': dosage},
          ],
        if (history.isNotEmpty)
          'note': [
            for (final c in history)
              {
                'text':
                    '${formatIsoDate(c.date)}: ${c.kind.label}'
                    '${c.dose.isNotEmpty ? ' — ${c.dose}' : ''}'
                    '${c.note.isNotEmpty ? ' (${c.note})' : ''}',
              },
          ],
      },
    });
  }

  return {
    'resourceType': 'Bundle',
    'id': uuidV4(random),
    'meta': {'lastUpdated': isoWithOffset(generatedAt)},
    'type': 'collection',
    'timestamp': isoWithOffset(generatedAt),
    'entry': entries,
  };
}

String encodeFhirBundle(Map<String, Object?> bundle) =>
    const JsonEncoder.withIndent('  ').convert(bundle);
