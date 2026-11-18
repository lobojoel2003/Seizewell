import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Biometric / device-credential check for the optional app lock.
abstract interface class DeviceAuth {
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

class LocalDeviceAuth implements DeviceAuth {
  final _auth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on Object catch (e) {
      debugPrint('Authentication failed: $e');
      return false;
    }
  }
}

/// A file to hand to the system share sheet.
class ShareableFile {
  const ShareableFile(this.name, this.bytes, this.mimeType);

  ShareableFile.text(this.name, String text, this.mimeType)
    : bytes = Uint8List.fromList(utf8.encode(text));

  final String name;
  final Uint8List bytes;
  final String mimeType;
}

/// Everything that touches the operating system, behind one interface so
/// widget tests can run without platform channels.
abstract interface class PlatformBridge {
  Future<void> keepScreenOn(bool on);
  Future<void> dial(String number);
  Future<void> openUrl(String url);

  /// Writes [files] to a private temporary folder and opens the share sheet.
  /// Returns false if the user dismissed it.
  Future<bool> shareFiles(List<ShareableFile> files, {String? subject});

  /// Removes temporary export files left behind by earlier shares.
  Future<void> clearExportCache();
}

class DevicePlatformBridge implements PlatformBridge {
  @override
  Future<void> keepScreenOn(bool on) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } on Object catch (e) {
      debugPrint('Wakelock: $e');
    }
  }

  @override
  Future<void> dial(String number) async {
    final cleaned = number.replaceAll(RegExp(r'[^0-9+*#]'), '');
    if (cleaned.isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: cleaned));
  }

  @override
  Future<void> openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<Directory> _exportDir() async {
    final dir = Directory(
      p.join((await getTemporaryDirectory()).path, 'exports'),
    );
    await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<bool> shareFiles(List<ShareableFile> files, {String? subject}) async {
    final dir = await _exportDir();
    final xfiles = <XFile>[];
    for (final f in files) {
      final file = File(p.join(dir.path, f.name));
      await file.writeAsBytes(f.bytes, flush: true);
      xfiles.add(XFile(file.path, mimeType: f.mimeType, name: f.name));
    }
    final result = await SharePlus.instance.share(
      ShareParams(files: xfiles, subject: subject),
    );
    return result.status != ShareResultStatus.dismissed;
  }

  @override
  Future<void> clearExportCache() async {
    try {
      final dir = Directory(
        p.join((await getTemporaryDirectory()).path, 'exports'),
      );
      if (await dir.exists()) await dir.delete(recursive: true);
    } on Object catch (e) {
      debugPrint('Export cache: $e');
    }
  }
}
