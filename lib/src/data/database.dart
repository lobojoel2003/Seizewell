import 'package:drift/drift.dart';

import '../domain/types.dart';
import 'converters.dart';

export 'converters.dart';

part 'database.g.dart';

/// One seizure event. A row with a `null` [endedAt] is the seizure that is
/// currently being timed (there is at most one).
class Seizures extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  /// False when nobody saw the start or the end (for example a seizure
  /// during sleep). Unknown durations are excluded from duration statistics.
  BoolColumn get durationKnown => boolean().withDefault(const Constant(true))();
  TextColumn get type =>
      textEnum<SeizureType>().withDefault(Constant(SeizureType.unknown.name))();
  BoolColumn get aura => boolean().withDefault(const Constant(false))();
  BoolColumn get duringSleep => boolean().withDefault(const Constant(false))();
  BoolColumn get injury => boolean().withDefault(const Constant(false))();
  BoolColumn get emergencyCare =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get rescueGivenAt => dateTime().nullable()();
  TextColumn get rescueMedication => text().nullable()();
  TextColumn get loggedBy =>
      textEnum<Reporter>().withDefault(Constant(Reporter.patient.name))();
  TextColumn get notes => text().withDefault(const Constant(''))();

  /// Set once someone has reviewed the entry in the editor. Seizures logged
  /// with the one-tap timer start out incomplete so the app can gently ask
  /// for details later.
  BoolColumn get detailsCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Possible seizure triggers. Built-in triggers are seeded on first launch;
/// users can add their own.
@DataClassName('TriggerTag')
class Triggers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60).unique()();
  BoolColumn get builtIn => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(100))();
}

@DataClassName('SeizureTriggerLink')
class SeizureTriggers extends Table {
  IntColumn get seizureId =>
      integer().references(Seizures, #id, onDelete: KeyAction.cascade)();
  IntColumn get triggerId =>
      integer().references(Triggers, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {seizureId, triggerId};
}

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get kind => textEnum<MedicationKind>()();
  TextColumn get dose => text().withDefault(const Constant(''))();
  TextColumn get schedule => text().withDefault(const Constant(''))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// A start, dose change or stop of a medication. These are drawn on the
/// clinic report's timeline so the neurologist can see what changed when.
class MedicationChanges extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId =>
      integer().references(Medications, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text().map(const DateOnlyConverter())();
  TextColumn get kind => textEnum<MedicationChangeKind>()();
  TextColumn get dose => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
}

/// Sleep for one night, keyed by the date the person woke up.
class SleepLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get night => text().map(const DateOnlyConverter()).unique()();
  RealColumn get hours => real()();
  IntColumn get quality => integer().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// Small key/value store for preferences, profile and the emergency plan.
/// Lives inside the encrypted database so nothing personal sits in plain
/// shared preferences.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Built-in triggers, in display order.
const builtInTriggers = <String>[
  'Missed medication',
  'Lack of sleep',
  'Stress',
  'Illness or fever',
  'Menstrual cycle',
  'Alcohol',
  'Flashing lights',
  'Skipped meal',
  'Dehydration',
  'Overheating',
  'New medication',
  'Excitement',
];

@DriftDatabase(
  tables: [
    Seizures,
    Triggers,
    SeizureTriggers,
    Medications,
    MedicationChanges,
    SleepLogs,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Bump when the schema changes and add a step to [migration].
  static const currentSchemaVersion = 1;

  /// Tables in dependency order (parents first). Used by backup restore.
  static const tableNamesInOrder = <String>[
    'seizures',
    'triggers',
    'seizure_triggers',
    'medications',
    'medication_changes',
    'sleep_logs',
    'settings',
  ];

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedBuiltInTriggers();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> seedBuiltInTriggers() async {
    await batch((b) {
      for (var i = 0; i < builtInTriggers.length; i++) {
        b.insert(
          triggers,
          TriggersCompanion.insert(
            name: builtInTriggers[i],
            builtIn: const Value(true),
            sortOrder: Value(i),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  /// Removes every diary entry and preference, then re-seeds the defaults.
  Future<void> deleteEverything() async {
    await transaction(() async {
      for (final table in allTables.toList().reversed) {
        await delete(table).go();
      }
      await seedBuiltInTriggers();
    });
  }
}
