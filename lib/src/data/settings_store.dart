import 'package:flutter/foundation.dart';

import '../domain/emergency_plan.dart';
import '../domain/types.dart';
import 'database.dart';
import 'queries.dart';

enum AppThemeMode { system, light, dark }

enum PaperSize {
  letter('US Letter'),
  a4('A4');

  const PaperSize(this.label);
  final String label;
}

/// Preferences, profile and emergency plan, persisted in the encrypted
/// database and cached in memory so the UI can read them synchronously.
class SettingsStore extends ChangeNotifier {
  SettingsStore._(this._db, this._countryCode);

  final AppDatabase _db;
  final String? _countryCode;

  static const _kName = 'profile.name';
  static const _kDob = 'profile.dateOfBirth';
  static const _kRole = 'profile.role';
  static const _kPlan = 'emergency.plan';
  static const _kTheme = 'ui.theme';
  static const _kLock = 'security.appLock';
  static const _kOnboarding = 'onboarding.done';
  static const _kPaper = 'report.paper';
  static const _kLastBackup = 'backup.last';

  String _patientName = '';
  DateTime? _dateOfBirth;
  Reporter _role = Reporter.caregiver;
  EmergencyPlan _plan = const EmergencyPlan();
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _appLockEnabled = false;
  bool _onboardingDone = false;
  PaperSize _paperSize = PaperSize.letter;
  DateTime? _lastBackupAt;

  static Future<SettingsStore> load(
    AppDatabase db, {
    String? countryCode,
  }) async {
    final store = SettingsStore._(db, countryCode);
    await store.reload();
    return store;
  }

  /// Re-reads everything from the database (after a restore, for example).
  Future<void> reload() async {
    final raw = await _db.readAllSettings();
    final defaults = EmergencyPlan(
      emergencyNumber: EmergencyPlan.defaultEmergencyNumber(_countryCode),
    );
    _patientName = raw[_kName] ?? '';
    _dateOfBirth = DateTime.tryParse(raw[_kDob] ?? '');
    _role = Reporter.values.asNameMap()[raw[_kRole]] ?? Reporter.caregiver;
    _plan = EmergencyPlan.decode(raw[_kPlan], fallback: defaults);
    _themeMode =
        AppThemeMode.values.asNameMap()[raw[_kTheme]] ?? AppThemeMode.system;
    _appLockEnabled = raw[_kLock] == 'true';
    _onboardingDone = raw[_kOnboarding] == 'true';
    _paperSize =
        PaperSize.values.asNameMap()[raw[_kPaper]] ??
        (const {'US', 'CA', 'MX', 'PH'}.contains(_countryCode?.toUpperCase())
            ? PaperSize.letter
            : PaperSize.a4);
    _lastBackupAt = DateTime.tryParse(raw[_kLastBackup] ?? '');
    notifyListeners();
  }

  String get patientName => _patientName;
  DateTime? get dateOfBirth => _dateOfBirth;

  /// Who usually logs seizures on this phone; used as the default author.
  Reporter get role => _role;
  EmergencyPlan get plan => _plan;
  AppThemeMode get themeMode => _themeMode;
  bool get appLockEnabled => _appLockEnabled;
  bool get onboardingDone => _onboardingDone;
  PaperSize get paperSize => _paperSize;
  DateTime? get lastBackupAt => _lastBackupAt;

  Future<void> _put(String key, String? value) async {
    await _db.writeSetting(key, value);
    notifyListeners();
  }

  Future<void> setPatientName(String value) {
    _patientName = value.trim();
    return _put(_kName, _patientName);
  }

  Future<void> setDateOfBirth(DateTime? value) {
    _dateOfBirth = value == null ? null : dateOnly(value);
    return _put(_kDob, _dateOfBirth == null ? null : formatIsoDate(value!));
  }

  Future<void> setRole(Reporter value) {
    _role = value;
    return _put(_kRole, value.name);
  }

  Future<void> setPlan(EmergencyPlan value) {
    _plan = value;
    return _put(_kPlan, value.encode());
  }

  Future<void> setThemeMode(AppThemeMode value) {
    _themeMode = value;
    return _put(_kTheme, value.name);
  }

  Future<void> setAppLockEnabled(bool value) {
    _appLockEnabled = value;
    return _put(_kLock, '$value');
  }

  Future<void> setOnboardingDone(bool value) {
    _onboardingDone = value;
    return _put(_kOnboarding, '$value');
  }

  Future<void> setPaperSize(PaperSize value) {
    _paperSize = value;
    return _put(_kPaper, value.name);
  }

  Future<void> setLastBackupAt(DateTime value) {
    _lastBackupAt = value;
    return _put(_kLastBackup, value.toIso8601String());
  }
}
