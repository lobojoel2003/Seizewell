import 'package:drift/drift.dart';

import '../domain/types.dart';
import 'database.dart';

/// A seizure together with the triggers recorded for it.
class SeizureEntry {
  const SeizureEntry(this.seizure, this.triggers);

  final Seizure seizure;
  final List<TriggerTag> triggers;

  int get id => seizure.id;
  DateTime get startedAt => seizure.startedAt;
  bool get isActive => seizure.endedAt == null;

  /// The measured duration, or `null` while active or when unknown.
  Duration? get duration {
    final end = seizure.endedAt;
    if (end == null || !seizure.durationKnown) return null;
    return end.difference(seizure.startedAt);
  }
}

class MedicationChangeEntry {
  const MedicationChangeEntry(this.change, this.medication);
  final MedicationChange change;
  final Medication medication;
}

extension SeizureQueries on AppDatabase {
  SimpleSelectStatement<$SeizuresTable, Seizure> _activeQuery() =>
      select(seizures)
        ..where((s) => s.endedAt.isNull())
        ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
        ..limit(1);

  Stream<Seizure?> watchActiveSeizure() => _activeQuery().watchSingleOrNull();

  Future<Seizure?> activeSeizure() => _activeQuery().getSingleOrNull();

  Future<Seizure> seizureById(int id) =>
      (select(seizures)..where((s) => s.id.equals(id))).getSingle();

  /// Starts timing a seizure. If one is already being timed, returns it
  /// instead of starting a second one (double taps are common under stress);
  /// `created` tells the two cases apart.
  Future<({Seizure seizure, bool created})> startSeizure({
    required DateTime at,
    required Reporter loggedBy,
  }) {
    return transaction(() async {
      final existing = await activeSeizure();
      if (existing != null) return (seizure: existing, created: false);
      final id = await into(seizures).insert(
        SeizuresCompanion.insert(
          startedAt: at,
          loggedBy: Value(loggedBy),
          createdAt: Value(at),
          updatedAt: Value(at),
        ),
      );
      return (seizure: await seizureById(id), created: true);
    });
  }

  /// Ends the seizure if it is still running. Returns false if it had
  /// already ended (for example a second "Seizure ended" tap), so the first
  /// end time is never overwritten.
  Future<bool> endSeizure(int id, DateTime at) async {
    final s = await seizureById(id);
    final end = at.isBefore(s.startedAt) ? s.startedAt : at;
    final updated =
        await (update(
          seizures,
        )..where((t) => t.id.equals(id) & t.endedAt.isNull())).write(
          SeizuresCompanion(endedAt: Value(end), updatedAt: Value(at)),
        );
    return updated > 0;
  }

  /// "It started earlier": moves the start of the running seizure back.
  Future<Seizure> moveSeizureStart(int id, DateTime start) async {
    await (update(seizures)..where((t) => t.id.equals(id))).write(
      SeizuresCompanion(startedAt: Value(start)),
    );
    return seizureById(id);
  }

  /// Undo for "Seizure ended" pressed too early.
  Future<void> resumeSeizure(int id) => transaction(() async {
    final other = await activeSeizure();
    if (other != null && other.id != id) return;
    await (update(seizures)..where((t) => t.id.equals(id))).write(
      const SeizuresCompanion(endedAt: Value(null)),
    );
  });

  Future<void> recordRescue(int id, DateTime at, String? medication) =>
      (update(seizures)..where((t) => t.id.equals(id))).write(
        SeizuresCompanion(
          rescueGivenAt: Value(at),
          rescueMedication: Value(medication),
          updatedAt: Value(at),
        ),
      );

  Future<void> clearRescue(int id) =>
      (update(seizures)..where((t) => t.id.equals(id))).write(
        const SeizuresCompanion(
          rescueGivenAt: Value(null),
          rescueMedication: Value(null),
        ),
      );

  Future<void> deleteSeizure(int id) =>
      (delete(seizures)..where((t) => t.id.equals(id))).go();

  /// Inserts ([SeizuresCompanion.id] absent) or updates a seizure and
  /// replaces its triggers. Returns the seizure id.
  Future<int> saveSeizure(
    SeizuresCompanion data,
    Set<int> triggerIds, {
    required DateTime now,
  }) {
    return transaction(() async {
      final withMeta = data.copyWith(updatedAt: Value(now));
      int id;
      if (data.id.present) {
        id = data.id.value;
        await (update(seizures)..where((t) => t.id.equals(id))).write(withMeta);
      } else {
        id = await into(seizures)
            .insert(withMeta.copyWith(createdAt: Value(now)));
      }
      await (delete(
        seizureTriggers,
      )..where((l) => l.seizureId.equals(id))).go();
      await batch((b) {
        b.insertAll(seizureTriggers, [
          for (final t in triggerIds)
            SeizureTriggersCompanion.insert(seizureId: id, triggerId: t),
        ]);
      });
      return id;
    });
  }

  JoinedSelectStatement<HasResultSet, dynamic> _entryQuery() {
    return select(seizures).join([
      leftOuterJoin(
        seizureTriggers,
        seizureTriggers.seizureId.equalsExp(seizures.id),
      ),
      leftOuterJoin(triggers, triggers.id.equalsExp(seizureTriggers.triggerId)),
    ]);
  }

  List<SeizureEntry> _group(List<TypedResult> rows) {
    final order = <int>[];
    final bySeizure = <int, Seizure>{};
    final tags = <int, List<TriggerTag>>{};
    for (final row in rows) {
      final s = row.readTable(seizures);
      if (!bySeizure.containsKey(s.id)) {
        order.add(s.id);
        bySeizure[s.id] = s;
        tags[s.id] = [];
      }
      final t = row.readTableOrNull(triggers);
      if (t != null) tags[s.id]!.add(t);
    }
    return [
      for (final id in order)
        SeizureEntry(
          bySeizure[id]!,
          tags[id]!..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
        ),
    ];
  }

  JoinedSelectStatement<HasResultSet, dynamic> _finishedQuery({
    DateTime? from,
    DateTime? to,
  }) {
    final q = _entryQuery()
      ..where(seizures.endedAt.isNotNull())
      ..orderBy([OrderingTerm.desc(seizures.startedAt)]);
    if (from != null) q.where(seizures.startedAt.isBiggerOrEqualValue(from));
    if (to != null) q.where(seizures.startedAt.isSmallerThanValue(to));
    return q;
  }

  /// Finished seizures, newest first, optionally limited to `[from, to)`.
  Stream<List<SeizureEntry>> watchSeizures({DateTime? from, DateTime? to}) =>
      _finishedQuery(from: from, to: to).watch().map(_group);

  Future<List<SeizureEntry>> seizuresBetween(
    DateTime from,
    DateTime to,
  ) async => _group(await _finishedQuery(from: from, to: to).get());

  Future<List<SeizureEntry>> allSeizures() async =>
      _group(await _finishedQuery().get());

  Stream<List<SeizureEntry>> watchNeedingDetails() {
    final q = _entryQuery()
      ..where(
        seizures.endedAt.isNotNull() & seizures.detailsCompleted.equals(false),
      )
      ..orderBy([OrderingTerm.desc(seizures.startedAt)]);
    return q.watch().map(_group);
  }

  Future<SeizureEntry?> seizureEntry(int id) async {
    final q = _entryQuery()..where(seizures.id.equals(id));
    final grouped = _group(await q.get());
    return grouped.isEmpty ? null : grouped.single;
  }

  /// Most recent rescue-medication dose across all seizures.
  Stream<DateTime?> watchLastRescueDose() {
    final q = selectOnly(seizures)..addColumns([seizures.rescueGivenAt.max()]);
    return q.watchSingle().map((r) => r.read(seizures.rescueGivenAt.max()));
  }
}

extension TriggerQueries on AppDatabase {
  Future<List<TriggerTag>> allTriggers({bool includeArchived = false}) =>
      _triggersQuery(includeArchived).get();

  Stream<List<TriggerTag>> watchTriggers({bool includeArchived = false}) =>
      _triggersQuery(includeArchived).watch();

  SimpleSelectStatement<$TriggersTable, TriggerTag> _triggersQuery(
    bool includeArchived,
  ) {
    final q = select(triggers)
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.name),
      ]);
    if (!includeArchived) q.where((t) => t.archived.equals(false));
    return q;
  }

  /// Adds a custom trigger. Re-uses (and un-archives) an existing trigger
  /// with the same name, ignoring case.
  Future<TriggerTag> addTrigger(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('Trigger name is empty');
    return transaction(() async {
      final existing =
          await (select(triggers)
                ..where((t) => t.name.lower().equals(clean.toLowerCase())))
              .getSingleOrNull();
      if (existing != null) {
        if (existing.archived) {
          await (update(triggers)..where((t) => t.id.equals(existing.id)))
              .write(const TriggersCompanion(archived: Value(false)));
        }
        return existing.copyWith(archived: false);
      }
      final id = await into(triggers)
          .insert(TriggersCompanion.insert(name: clean));
      return (select(triggers)..where((t) => t.id.equals(id))).getSingle();
    });
  }

  Future<void> setTriggerArchived(int id, bool archived) =>
      (update(triggers)..where((t) => t.id.equals(id))).write(
        TriggersCompanion(archived: Value(archived)),
      );
}

extension MedicationQueries on AppDatabase {
  SimpleSelectStatement<$MedicationsTable, Medication> _medsQuery() =>
      select(medications)..orderBy([
        (m) => OrderingTerm.desc(m.active),
        (m) => OrderingTerm.asc(m.kind),
        (m) => OrderingTerm.asc(m.name),
      ]);

  Stream<List<Medication>> watchMedications() => _medsQuery().watch();

  Future<List<Medication>> allMedications() => _medsQuery().get();

  Future<Medication> medicationById(int id) =>
      (select(medications)..where((m) => m.id.equals(id))).getSingle();

  /// Adds a medication and records that it was started on [startedOn].
  Future<int> addMedication({
    required String name,
    required MedicationKind kind,
    required DateTime startedOn,
    String dose = '',
    String schedule = '',
    String notes = '',
  }) {
    return transaction(() async {
      final id = await into(medications).insert(
        MedicationsCompanion.insert(
          name: name.trim(),
          kind: kind,
          dose: Value(dose.trim()),
          schedule: Value(schedule.trim()),
          notes: Value(notes.trim()),
        ),
      );
      await into(medicationChanges).insert(
        MedicationChangesCompanion.insert(
          medicationId: id,
          date: dateOnly(startedOn),
          kind: MedicationChangeKind.started,
          dose: Value(dose.trim()),
        ),
      );
      return id;
    });
  }

  /// Saves edits. A different dose is recorded as a dose change on
  /// [changedOn] so it appears on the report timeline.
  Future<void> updateMedication(
    Medication updated, {
    required DateTime changedOn,
    String changeNote = '',
  }) {
    return transaction(() async {
      final before = await medicationById(updated.id);
      await update(medications).replace(updated);
      if (before.dose.trim() != updated.dose.trim() && updated.active) {
        await into(medicationChanges).insert(
          MedicationChangesCompanion.insert(
            medicationId: updated.id,
            date: dateOnly(changedOn),
            kind: MedicationChangeKind.doseChanged,
            dose: Value(updated.dose.trim()),
            note: Value(
              changeNote.isNotEmpty
                  ? changeNote
                  : before.dose.isEmpty
                  ? ''
                  : 'was ${before.dose.trim()}',
            ),
          ),
        );
      }
    });
  }

  Future<void> stopMedication(int id, DateTime on, {String note = ''}) {
    return transaction(() async {
      await (update(medications)..where((m) => m.id.equals(id))).write(
        const MedicationsCompanion(active: Value(false)),
      );
      await into(medicationChanges).insert(
        MedicationChangesCompanion.insert(
          medicationId: id,
          date: dateOnly(on),
          kind: MedicationChangeKind.stopped,
          note: Value(note),
        ),
      );
    });
  }

  Future<void> restartMedication(int id, DateTime on, String dose) {
    return transaction(() async {
      await (update(medications)..where((m) => m.id.equals(id))).write(
        MedicationsCompanion(active: const Value(true), dose: Value(dose)),
      );
      await into(medicationChanges).insert(
        MedicationChangesCompanion.insert(
          medicationId: id,
          date: dateOnly(on),
          kind: MedicationChangeKind.started,
          dose: Value(dose),
        ),
      );
    });
  }

  Future<void> deleteMedication(int id) =>
      (delete(medications)..where((m) => m.id.equals(id))).go();

  Future<void> deleteMedicationChange(int id) =>
      (delete(medicationChanges)..where((c) => c.id.equals(id))).go();

  List<MedicationChangeEntry> _changeRows(List<TypedResult> rows) => [
    for (final r in rows)
      MedicationChangeEntry(
        r.readTable(medicationChanges),
        r.readTable(medications),
      ),
  ];

  JoinedSelectStatement<HasResultSet, dynamic> _changesQuery({
    int? medicationId,
  }) {
    final q =
        select(medicationChanges).join([
          innerJoin(
            medications,
            medications.id.equalsExp(medicationChanges.medicationId),
          ),
        ])..orderBy([
          OrderingTerm.desc(medicationChanges.date),
          OrderingTerm.desc(medicationChanges.id),
        ]);
    if (medicationId != null) {
      q.where(medicationChanges.medicationId.equals(medicationId));
    }
    return q;
  }

  Stream<List<MedicationChangeEntry>> watchMedicationChanges({
    int? medicationId,
  }) => _changesQuery(medicationId: medicationId).watch().map(_changeRows);

  Future<List<MedicationChangeEntry>> allMedicationChanges() async =>
      _changeRows(await _changesQuery().get());
}

extension SleepQueries on AppDatabase {
  SimpleSelectStatement<$SleepLogsTable, SleepLog> _sleepQuery({int? limit}) {
    final q = select(sleepLogs)..orderBy([(s) => OrderingTerm.desc(s.night)]);
    if (limit != null) q.limit(limit);
    return q;
  }

  Stream<List<SleepLog>> watchSleep({int? limit}) =>
      _sleepQuery(limit: limit).watch();

  Future<List<SleepLog>> allSleep() => _sleepQuery().get();

  Stream<SleepLog?> watchSleepFor(DateTime night) => (select(
    sleepLogs,
  )..where((s) => s.night.equals(formatIsoDate(night)))).watchSingleOrNull();

  Future<void> upsertSleep({
    required DateTime night,
    required double hours,
    int? quality,
    String notes = '',
  }) {
    return into(sleepLogs).insert(
      SleepLogsCompanion.insert(
        night: dateOnly(night),
        hours: hours,
        quality: Value(quality),
        notes: Value(notes),
      ),
      onConflict: DoUpdate(
        (_) => SleepLogsCompanion(
          hours: Value(hours),
          quality: Value(quality),
          notes: Value(notes),
        ),
        target: [sleepLogs.night],
      ),
    );
  }

  Future<void> deleteSleep(int id) =>
      (delete(sleepLogs)..where((s) => s.id.equals(id))).go();
}

extension SettingsQueries on AppDatabase {
  Future<Map<String, String>> readAllSettings() async {
    final rows = await select(settings).get();
    return {for (final r in rows) r.key: r.value};
  }

  Future<void> writeSetting(String key, String? value) async {
    if (value == null) {
      await (delete(settings)..where((s) => s.key.equals(key))).go();
    } else {
      await into(settings).insertOnConflictUpdate(
        SettingsCompanion.insert(key: key, value: value),
      );
    }
  }
}
