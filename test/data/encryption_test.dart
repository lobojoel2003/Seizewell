import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:seizewell/src/data/connection.dart';
import 'package:seizewell/src/data/database.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('seizewell_enc_');
  });

  tearDown(() async {
    await tmp.delete(recursive: true);
  });

  test('SQLCipher is linked', () async {
    final db = openTestDatabase();
    final row = await db.customSelect('PRAGMA cipher_version').getSingle();
    expect(row.data.values.first, isNotNull);
    await db.close();
  });

  test('database file is encrypted at rest and reopens with its key', () async {
    final file = File('${tmp.path}/diary.db');
    final keys = MemoryDatabaseKeyStore();
    var db = await openEncryptedDatabase(file: file, keyStore: keys);
    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(key: 'probe', value: 'Very private note'),
        );
    await db.close();

    final bytes = await file.readAsBytes();
    expect(String.fromCharCodes(bytes).contains('Very private note'), isFalse);
    expect(
      String.fromCharCodes(bytes.take(16)).startsWith('SQLite format'),
      isFalse,
      reason: 'An unencrypted SQLite file starts with "SQLite format 3"',
    );

    db = await openEncryptedDatabase(file: file, keyStore: keys);
    final value = await (db.select(
      db.settings,
    )..where((s) => s.key.equals('probe'))).getSingle();
    expect(value.value, 'Very private note');
    await db.close();
  });

  test('wrong key is rejected', () async {
    final file = File('${tmp.path}/diary.db');
    final keys = MemoryDatabaseKeyStore();
    final db = await openEncryptedDatabase(file: file, keyStore: keys);
    await db.close();

    await expectLater(
      openEncryptedDatabase(
        file: file,
        keyStore: MemoryDatabaseKeyStore(generateDatabaseKey()),
      ),
      throwsA(isA<DatabaseLockedException>()),
    );
  });

  test('missing key for an existing database is reported', () async {
    final file = File('${tmp.path}/diary.db');
    final keys = MemoryDatabaseKeyStore();
    final db = await openEncryptedDatabase(file: file, keyStore: keys);
    await db.close();
    await keys.delete();

    await expectLater(
      openEncryptedDatabase(file: file, keyStore: keys),
      throwsA(isA<DatabaseLockedException>()),
    );
  });

  test('built-in triggers are seeded', () async {
    final db = openTestDatabase();
    final all = await db.select(db.triggers).get();
    expect(all.map((t) => t.name), containsAll(builtInTriggers));
    await db.close();
  });
}
