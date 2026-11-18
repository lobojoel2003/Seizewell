import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:seizewell/src/data/connection.dart';
import 'package:seizewell/src/data/database.dart';
import 'package:seizewell/src/data/queries.dart';
import 'package:seizewell/src/domain/types.dart';
import 'package:seizewell/src/services/backup_service.dart';

void main() {
  late Directory tmp;
  late AppDatabase source;
  final now = DateTime(2026, 11, 18, 10);

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('seizewell_backup_');
    source = await openEncryptedDatabase(
      file: File('${tmp.path}/source.db'),
      keyStore: MemoryDatabaseKeyStore(),
    );
    final stress = (await source.watchTriggers().first).first;
    final custom = await source.addTrigger('Video games');
    await source.saveSeizure(
      SeizuresCompanion.insert(
        startedAt: DateTime(2026, 11, 1, 8),
        endedAt: Value(DateTime(2026, 11, 1, 8, 2)),
        type: const Value(SeizureType.tonicClonic),
        notes: const Value('Fell in kitchen'),
      ),
      {stress.id, custom.id},
      now: now,
    );
    await source.addMedication(
      name: 'Valproate',
      kind: MedicationKind.maintenance,
      dose: '500 mg',
      startedOn: DateTime(2026, 1, 1),
    );
    await source.upsertSleep(night: DateTime(2026, 11, 1), hours: 5);
    await source.writeSetting('profile.name', 'Alex');
  });

  tearDown(() async {
    await source.close();
    await tmp.delete(recursive: true);
  });

  test('backup round-trips into another encrypted database', () async {
    final file = await BackupService(source).createBackup(
      passphrase: 'correct horse battery',
      directory: tmp,
      now: now,
    );
    expect(file.path, endsWith('seizewell-backup-2026-11-18.seizewell'));
    final raw = String.fromCharCodes(await file.readAsBytes());
    expect(raw.contains('Fell in kitchen'), isFalse);
    expect(raw.startsWith('SQLite format'), isFalse);

    final target = await openEncryptedDatabase(
      file: File('${tmp.path}/target.db'),
      keyStore: MemoryDatabaseKeyStore(),
    );
    await target.startSeizure(at: now, loggedBy: Reporter.patient);

    final count = await BackupService(target)
        .restoreBackup(file: file, passphrase: 'correct horse battery');
    expect(count, 1);

    final entries = await target.allSeizures();
    expect(entries.single.seizure.notes, 'Fell in kitchen');
    expect(
      entries.single.triggers.map((t) => t.name),
      containsAll(['Video games']),
    );
    expect(await target.activeSeizure(), isNull);
    expect((await target.allMedications()).single.name, 'Valproate');
    expect((await target.allMedicationChanges()), hasLength(1));
    expect((await target.allSleep()).single.hours, 5);
    expect((await target.readAllSettings())['profile.name'], 'Alex');
    await target.close();
  });

  test('wrong passphrase is rejected and leaves data untouched', () async {
    final file = await BackupService(source).createBackup(
      passphrase: 'correct horse battery',
      directory: tmp,
      now: now,
    );
    final target = openTestDatabase();
    await target.startSeizure(at: now, loggedBy: Reporter.patient);

    await expectLater(
      BackupService(target)
          .restoreBackup(file: file, passphrase: 'nope nope nope'),
      throwsA(isA<BackupException>()),
    );
    expect(await target.activeSeizure(), isNotNull);
    await target.close();
  });

  test('short passphrases are refused', () async {
    await expectLater(
      BackupService(source)
          .createBackup(passphrase: 'short', directory: tmp, now: now),
      throwsA(isA<BackupException>()),
    );
  });

  test('a random file is not accepted as a backup', () async {
    final junk = File('${tmp.path}/junk.seizewell')
      ..writeAsBytesSync(List.filled(4096, 7));
    await expectLater(
      BackupService(source)
          .restoreBackup(file: junk, passphrase: 'whatever123'),
      throwsA(isA<BackupException>()),
    );
  });
}
