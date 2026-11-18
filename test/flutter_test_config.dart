import 'dart:async';

import 'package:drift/drift.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Tests deliberately open several independent in-memory databases.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}
