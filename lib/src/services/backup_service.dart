import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../data/database.dart';

class BackupException implements Exception {
  const BackupException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Encrypted, passphrase-protected backups.
///
/// A backup is a complete SQLCipher database encrypted with a key derived
/// from the user's passphrase (SQLCipher 4 defaults: PBKDF2-HMAC-SHA512,
/// 256,000 iterations, AES-256 with per-page HMAC). It is the only way data
/// leaves the phone, and only when the user explicitly shares the file.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  static const fileExtension = 'seizewell';
  static const minPassphraseLength = 8;

  static String fileNameFor(DateTime now) =>
      'seizewell-backup-${formatIsoDate(now)}.$fileExtension';

  Future<File> createBackup({
    required String passphrase,
    required Directory directory,
    required DateTime now,
  }) async {
    _checkPassphrase(passphrase);
    final file = File(p.join(directory.path, fileNameFor(now)));
    if (await file.exists()) await file.delete();

    await _db.customStatement('ATTACH DATABASE ? AS backup KEY ?', [
      file.path,
      passphrase,
    ]);
    try {
      await _db.customSelect("SELECT sqlcipher_export('backup')").get();
      await _db.customStatement(
        'PRAGMA backup.user_version = ${AppDatabase.currentSchemaVersion}',
      );
    } finally {
      await _db.customStatement('DETACH DATABASE backup');
    }
    return file;
  }

  /// Replaces everything in the diary with the backup's contents.
  /// Returns the number of seizures restored.
  Future<int> restoreBackup({
    required File file,
    required String passphrase,
  }) async {
    if (!await file.exists()) {
      throw const BackupException('The backup file could not be found.');
    }
    try {
      await _db.customStatement('ATTACH DATABASE ? AS backup KEY ?', [
        file.path,
        passphrase,
      ]);
    } on Object {
      throw const BackupException('This file could not be opened.');
    }

    try {
      final List<String> backupTables;
      try {
        backupTables =
            (await _db
                    .customSelect(
                      "SELECT name FROM backup.sqlite_master WHERE type = 'table'",
                    )
                    .get())
                .map((r) => r.read<String>('name'))
                .toList();
      } on Object {
        throw const BackupException(
          'Wrong passphrase, or this is not a Seizewell backup.',
        );
      }
      if (!backupTables.contains('seizures')) {
        throw const BackupException('This is not a Seizewell backup.');
      }
      final version =
          (await _db.customSelect('PRAGMA backup.user_version').getSingle())
                  .data
                  .values
                  .first
              as int;
      if (version > AppDatabase.currentSchemaVersion) {
        throw const BackupException(
          'This backup was made by a newer version of Seizewell. '
          'Update the app, then try again.',
        );
      }

      var restored = 0;
      await _db.transaction(() async {
        for (final table in AppDatabase.tableNamesInOrder.reversed) {
          await _db.customStatement('DELETE FROM main."$table"');
        }
        for (final table in AppDatabase.tableNamesInOrder) {
          if (!backupTables.contains(table)) continue;
          final mainCols = await _columns('main', table);
          final backupCols = await _columns('backup', table);
          final cols = mainCols.where(backupCols.contains).toList();
          if (cols.isEmpty) continue;
          final list = cols.map((c) => '"$c"').join(', ');
          await _db.customStatement(
            'INSERT INTO main."$table" ($list) SELECT $list FROM backup."$table"',
          );
        }
        if (!backupTables.contains('triggers')) {
          await _db.seedBuiltInTriggers();
        }
        // A seizure that was being timed when the backup was made is long
        // over: keep it, but as "duration unknown" and needing details.
        await _db.customStatement(
          'UPDATE main.seizures SET ended_at = started_at, '
          'duration_known = 0, details_completed = 0 '
          'WHERE ended_at IS NULL',
        );
        restored =
            (await _db
                    .customSelect('SELECT count(*) AS c FROM main.seizures')
                    .getSingle())
                .read<int>('c');
      });
      _db.notifyUpdates({
        for (final t in _db.allTables) TableUpdate.onTable(t),
      });
      return restored;
    } finally {
      await _db.customStatement('DETACH DATABASE backup');
    }
  }

  Future<List<String>> _columns(String schema, String table) async {
    final rows = await _db
        .customSelect('PRAGMA $schema.table_info("$table")')
        .get();
    return [for (final r in rows) r.read<String>('name')];
  }

  void _checkPassphrase(String passphrase) {
    if (passphrase.length < minPassphraseLength) {
      throw const BackupException(
        'Use a passphrase of at least $minPassphraseLength characters.',
      );
    }
  }
}
