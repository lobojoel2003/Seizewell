import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'src/app.dart';
import 'src/app_services.dart';
import 'src/data/connection.dart';
import 'src/data/settings_store.dart';
import 'src/services/alerts.dart';
import 'src/services/launch_actions.dart';
import 'src/services/platform_services.dart';
import 'src/ui/startup_error_screen.dart';
import 'src/ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'Inter font',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  await _configureDateFormats();
  runApp(const SeizewellBootstrap());
}

/// The UI is English-only for now; dates follow the phone's English variant
/// (for example 18 Nov 2026 in the UK, Nov 18, 2026 in the US).
Future<void> _configureDateFormats() async {
  final locale = PlatformDispatcher.instance.locale;
  if (locale.languageCode != 'en') return;
  final tag = locale.toLanguageTag().replaceAll('-', '_');
  await initializeDateFormatting();
  Intl.defaultLocale = Intl.verifiedLocale(
    tag,
    DateFormat.localeExists,
    onFailure: (_) => 'en_US',
  );
}

Future<AppServices> createServices() async {
  final keyStore = SecureDatabaseKeyStore();
  final file = await defaultDatabaseFile();
  final db = await openEncryptedDatabase(file: file, keyStore: keyStore);
  final settings = await SettingsStore.load(
    db,
    countryCode: PlatformDispatcher.instance.locale.countryCode,
  );
  final info = await PackageInfo.fromPlatform();
  final platform = DevicePlatformBridge();
  unawaited(platform.clearExportCache());
  return AppServices(
    db: db,
    settings: settings,
    alerts: LocalNotificationAlerts(),
    launch: PlatformLaunchActions(),
    auth: LocalDeviceAuth(),
    platform: platform,
    info: AppInfo(version: info.version, buildNumber: info.buildNumber),
  );
}

/// Opens the encrypted database, then hands over to [SeizewellApp].
class SeizewellBootstrap extends StatefulWidget {
  const SeizewellBootstrap({super.key});

  @override
  State<SeizewellBootstrap> createState() => _SeizewellBootstrapState();
}

class _SeizewellBootstrapState extends State<SeizewellBootstrap> {
  AppServices? _services;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    setState(() => _error = null);
    try {
      final services = await createServices();
      if (mounted) setState(() => _services = services);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _erase() async {
    await destroyDatabase(
      file: await defaultDatabaseFile(),
      keyStore: SecureDatabaseKeyStore(),
    );
    await _open();
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    if (services != null) return SeizewellApp(services: services);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: _error == null
          ? const ColoredBox(color: brandNight)
          : StartupErrorScreen(error: _error!, onRetry: _open, onErase: _erase),
    );
  }
}
