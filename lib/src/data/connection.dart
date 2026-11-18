import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';

import 'database.dart';

/// File name of the encrypted diary database.
const databaseFileName = 'seizewell.db';

/// Thrown when the database exists but cannot be decrypted (for example the
/// key was removed from the system keystore).
class DatabaseLockedException implements Exception {
  const DatabaseLockedException(this.message);
  final String message;

  @override
  String toString() => 'DatabaseLockedException: $message';
}

/// Creates a random 256-bit key, hex encoded.
String generateDatabaseKey([Random? random]) {
  final rng = random ?? Random.secure();
  final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

bool isValidKeyHex(String key) => RegExp(r'^[0-9a-f]{64}$').hasMatch(key);

/// Keys the connection with SQLCipher. Must run before any other statement.
///
/// The key is a raw 256-bit key (`x'…'`), so SQLCipher skips its own key
/// derivation; the key itself never leaves the platform keystore except to
/// open the database.
void applyCipherKey(CommonDatabase db, String keyHex) {
  if (!isValidKeyHex(keyHex)) {
    throw ArgumentError('Database key must be 64 lowercase hex characters.');
  }
  final cipher = db.select('PRAGMA cipher_version;');
  if (cipher.isEmpty) {
    throw StateError(
      'SQLCipher is not available — refusing to store health data '
      'without encryption.',
    );
  }
  db.execute("PRAGMA key = \"x'$keyHex'\";");
  // Fails with SQLITE_NOTADB if the key is wrong.
  db.select('SELECT count(*) FROM sqlite_master;');
}

/// Abstraction over the platform keystore so tests can use memory.
abstract interface class DatabaseKeyStore {
  Future<String?> read();
  Future<void> write(String key);
  Future<void> delete();
}

/// Keeps the database key in the Android Keystore / iOS Keychain. The key is
/// bound to this device: it is not synced to iCloud Keychain and not part of
/// device backups, so the diary can only be moved with an explicit,
/// passphrase-protected Seizewell backup.
class SecureDatabaseKeyStore implements DatabaseKeyStore {
  SecureDatabaseKeyStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  static const _keyName = 'seizewell.database.key.v1';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _keyName);

  @override
  Future<void> write(String key) => _storage.write(key: _keyName, value: key);

  @override
  Future<void> delete() => _storage.delete(key: _keyName);
}

class MemoryDatabaseKeyStore implements DatabaseKeyStore {
  MemoryDatabaseKeyStore([this._key]);
  String? _key;

  @override
  Future<String?> read() async => _key;

  @override
  Future<void> write(String key) async => _key = key;

  @override
  Future<void> delete() async => _key = null;
}

Future<File> defaultDatabaseFile() async {
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  return File(p.join(dir.path, databaseFileName));
}

/// Opens (or creates) the encrypted database at [file].
Future<AppDatabase> openEncryptedDatabase({
  required File file,
  required DatabaseKeyStore keyStore,
}) async {
  var key = await keyStore.read();
  if (key == null) {
    if (await file.exists() && await file.length() > 0) {
      throw const DatabaseLockedException(
        'The diary database exists but its key is missing from the keystore.',
      );
    }
    key = generateDatabaseKey();
    await keyStore.write(key);
  }
  final keyHex = key;
  final db = AppDatabase(
    NativeDatabase.createInBackground(
      file,
      setup: (raw) => applyCipherKey(raw, keyHex),
    ),
  );
  try {
    // Opening is lazy; run a query so key problems surface now.
    await db.customSelect('SELECT 1').get();
  } on Object catch (e) {
    await db.close();
    throw DatabaseLockedException('Could not open the diary database: $e');
  }
  return db;
}

/// Deletes the database file and its key. Used by "Erase and start over"
/// when the database cannot be unlocked.
Future<void> destroyDatabase({
  required File file,
  required DatabaseKeyStore keyStore,
}) async {
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final f = File('${file.path}$suffix');
    if (await f.exists()) await f.delete();
  }
  await keyStore.delete();
}

/// An in-memory encrypted database, for tests.
AppDatabase openTestDatabase() => AppDatabase(
  DatabaseConnection(
    NativeDatabase.memory(
      setup: (raw) => applyCipherKey(raw, generateDatabaseKey(Random(1))),
    ),
    closeStreamsSynchronously: true,
  ),
);
