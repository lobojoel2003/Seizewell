import 'dart:math';

import 'package:drift/drift.dart';

import '../domain/emergency_plan.dart';
import '../domain/types.dart';
import 'database.dart';
import 'queries.dart';
import 'settings_store.dart';

/// Fills the database with six months of realistic, entirely fictional
/// diary data. Used for screenshots, tests and the "Explore with sample
/// data" option on the welcome screen.
Future<void> loadDemoData(
  AppDatabase db,
  SettingsStore settings, {
  required DateTime today,
  int seed = 7,
}) async {
  final rng = Random(seed);
  final t = DateTime(today.year, today.month, today.day);
  DateTime daysAgo(int d, [int hour = 0, int minute = 0]) =>
      DateTime(t.year, t.month, t.day - d, hour, minute);

  await settings.setPatientName('Sam Taylor');
  await settings.setDateOfBirth(DateTime(2011, 4, 12));
  await settings.setRole(Reporter.caregiver);
  await settings.setPlan(
    settings.plan.copyWith(
      rescueMedication: 'Midazolam nasal spray',
      rescueDose: '5 mg — one spray in one nostril',
      alertAfter: const Duration(minutes: 5),
      callAfterRescue: const Duration(minutes: 10),
      minHoursBetweenRescueDoses: () => 6,
      contacts: const [
        EmergencyContact(name: 'Jordan (parent)', phone: '+1 555 0100'),
        EmergencyContact(name: 'Dr. Okafor, neurology', phone: '+1 555 0142'),
      ],
      instructions:
          'Give rescue spray at 5 minutes.\n'
          'If still seizing 10 minutes after the spray, call 911.\n'
          'After the seizure: recovery position, let Sam sleep, check '
          'breathing every 15 minutes.',
    ),
  );

  final leve = await db.addMedication(
    name: 'Levetiracetam',
    kind: MedicationKind.maintenance,
    dose: '500 mg',
    schedule: 'Twice daily',
    startedOn: daysAgo(400),
  );
  await db.updateMedication(
    (await db.medicationById(leve)).copyWith(dose: '750 mg'),
    changedOn: daysAgo(118),
  );
  await db.updateMedication(
    (await db.medicationById(leve)).copyWith(dose: '1000 mg'),
    changedOn: daysAgo(64),
  );
  final lamo = await db.addMedication(
    name: 'Lamotrigine',
    kind: MedicationKind.maintenance,
    dose: '25 mg',
    schedule: 'Once daily',
    startedOn: daysAgo(36),
  );
  await db.updateMedication(
    (await db.medicationById(lamo)).copyWith(dose: '50 mg'),
    changedOn: daysAgo(15),
    changeNote: 'Titration step 2',
  );
  await db.addMedication(
    name: 'Midazolam nasal spray',
    kind: MedicationKind.rescue,
    dose: '5 mg',
    schedule: 'At 5 minutes',
    startedOn: daysAgo(400),
  );
  final clobazam = await db.addMedication(
    name: 'Clobazam',
    kind: MedicationKind.maintenance,
    dose: '5 mg',
    schedule: 'At night',
    startedOn: daysAgo(170),
  );
  await db.stopMedication(clobazam, daysAgo(88), note: 'Daytime drowsiness');

  final tags = {for (final tag in await db.allTriggers()) tag.name: tag.id};

  // Nightly sleep for the last ~4 months.
  for (var d = 120; d >= 0; d--) {
    final short = rng.nextDouble() < 0.18;
    final hours = short
        ? 4.5 + rng.nextDouble() * 1.4
        : 6.6 + rng.nextDouble() * 2.4;
    await db.upsertSleep(
      night: daysAgo(d),
      hours: (hours * 4).round() / 4,
      quality: short ? 2 : 3 + rng.nextInt(3),
    );
  }
  final sleep = {for (final s in await db.allSleep()) s.night: s.hours};

  Future<void> add({
    required int day,
    required SeizureType type,
    required int seconds,
    List<String> triggers = const [],
    bool duringSleep = false,
    bool aura = false,
    bool rescue = false,
    bool emergency = false,
    bool injury = false,
    String notes = '',
    bool complete = true,
    int? hour,
  }) async {
    final h = hour ?? (duringSleep ? 2 + rng.nextInt(4) : 7 + rng.nextInt(14));
    final start = daysAgo(day, h, rng.nextInt(60));
    final night = DateTime(start.year, start.month, start.day);
    final tagSet = {...triggers};
    if ((sleep[night] ?? 8) < 6) tagSet.add('Lack of sleep');
    await db.saveSeizure(
      SeizuresCompanion.insert(
        startedAt: start,
        endedAt: Value(start.add(Duration(seconds: seconds))),
        type: Value(type),
        duringSleep: Value(duringSleep),
        aura: Value(aura),
        injury: Value(injury),
        emergencyCare: Value(emergency),
        rescueGivenAt: Value(
          rescue ? start.add(const Duration(minutes: 5)) : null,
        ),
        rescueMedication: Value(rescue ? 'Midazolam nasal spray' : null),
        loggedBy: Value(rng.nextBool() ? Reporter.caregiver : Reporter.patient),
        notes: Value(notes),
        detailsCompleted: Value(complete),
      ),
      {for (final n in tagSet) tags[n]!},
      now: start,
    );
  }

  // Before the dose increase: frequent focal seizures.
  for (var day = 178; day > 118; day -= 2 + rng.nextInt(3)) {
    final roll = rng.nextDouble();
    await add(
      day: day,
      type: roll < 0.55
          ? SeizureType.focalImpaired
          : roll < 0.85
          ? SeizureType.focalAware
          : SeizureType.focalToBilateral,
      seconds: roll < 0.55
          ? 50 + rng.nextInt(100)
          : roll < 0.85
          ? 15 + rng.nextInt(40)
          : 100 + rng.nextInt(120),
      triggers: [
        if (rng.nextDouble() < 0.25) 'Stress',
        if (rng.nextDouble() < 0.12) 'Missed medication',
      ],
      aura: roll >= 0.55 && roll < 0.85,
    );
  }
  // After the first increase: fewer.
  for (var day = 116; day > 64; day -= 4 + rng.nextInt(4)) {
    final roll = rng.nextDouble();
    await add(
      day: day,
      type: roll < 0.6 ? SeizureType.focalImpaired : SeizureType.focalAware,
      seconds: roll < 0.6 ? 40 + rng.nextInt(80) : 15 + rng.nextInt(30),
      triggers: [if (rng.nextDouble() < 0.3) 'Stress'],
      duringSleep: rng.nextDouble() < 0.2,
    );
  }
  await add(
    day: 97,
    type: SeizureType.focalToBilateral,
    seconds: 6 * 60 + 40,
    triggers: ['Illness or fever'],
    rescue: true,
    emergency: true,
    injury: true,
    notes:
        'Started with right arm jerking, then whole body. Rescue spray at '
        '5 min, stopped about 90 s later. Paramedics checked, no hospital. '
        'Bitten tongue.',
  );
  // After adding lamotrigine: rare.
  for (var day = 60; day > 3; day -= 8 + rng.nextInt(9)) {
    await add(
      day: day,
      type: rng.nextDouble() < 0.7
          ? SeizureType.focalAware
          : SeizureType.focalImpaired,
      seconds: 20 + rng.nextInt(50),
      triggers: [if (rng.nextDouble() < 0.4) 'Stress'],
      duringSleep: rng.nextDouble() < 0.25,
    );
  }
  await add(
    day: 2,
    type: SeizureType.focalImpaired,
    seconds: 74,
    hour: 16,
    triggers: ['Missed medication'],
    notes: 'Stared and smacked lips during homework. Confused for ~10 min.',
  );
  // One quick-logged entry still waiting for details.
  await add(
    day: 0,
    type: SeizureType.unknown,
    seconds: 41,
    hour: 7,
    complete: false,
  );
}
