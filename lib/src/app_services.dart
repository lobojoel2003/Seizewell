import 'package:flutter/widgets.dart';

import 'data/database.dart';
import 'data/settings_store.dart';
import 'services/alerts.dart';
import 'services/launch_actions.dart';
import 'services/platform_services.dart';

/// Source of "now", replaceable in tests.
class Clock {
  const Clock();
  DateTime now() => DateTime.now();
}

class AppInfo {
  const AppInfo({required this.version, required this.buildNumber});
  final String version;
  final String buildNumber;

  String get display => '$version (build $buildNumber)';
}

/// Whether the diary is hidden behind the app lock.
class LockController extends ChangeNotifier {
  LockController({bool locked = false}) {
    _locked = locked;
  }

  late bool _locked;
  bool _overLockScreen = false;

  /// True while the diary must not be shown.
  bool get locked => _locked || _overLockScreen;

  /// True when Android is showing Seizewell on top of the phone's own lock
  /// screen (opened from the Quick Settings tile). Only the timer is
  /// reachable until the phone is unlocked.
  bool get overLockScreen => _overLockScreen;

  void lock() {
    if (_locked) return;
    _locked = true;
    notifyListeners();
  }

  void unlock() {
    if (!_locked) return;
    _locked = false;
    notifyListeners();
  }

  void enterLockScreenMode() {
    if (_overLockScreen) return;
    _overLockScreen = true;
    notifyListeners();
  }

  void leaveLockScreenMode() {
    if (!_overLockScreen) return;
    _overLockScreen = false;
    notifyListeners();
  }
}

/// The app's dependencies, created once in `main` (or by a test).
class AppServices {
  AppServices({
    required this.db,
    required this.settings,
    required this.alerts,
    required this.launch,
    required this.auth,
    required this.platform,
    required this.info,
    LockController? lock,
    this.clock = const Clock(),
  }) : lock = lock ?? LockController(locked: settings.appLockEnabled);

  final AppDatabase db;
  final SettingsStore settings;
  final SeizureAlerts alerts;
  final LaunchActions launch;
  final DeviceAuth auth;
  final PlatformBridge platform;
  final AppInfo info;
  final LockController lock;
  final Clock clock;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this widget');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}

extension AppScopeX on BuildContext {
  AppServices get services => AppScope.of(this);
}
