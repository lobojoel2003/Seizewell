import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seizewell/src/app.dart';
import 'package:seizewell/src/app_services.dart';
import 'package:seizewell/src/data/connection.dart';
import 'package:seizewell/src/data/database.dart';
import 'package:seizewell/src/data/settings_store.dart';
import 'package:seizewell/src/domain/emergency_plan.dart';
import 'package:seizewell/src/services/alerts.dart';
import 'package:seizewell/src/services/launch_actions.dart';
import 'package:seizewell/src/services/platform_services.dart';

class FakeClock extends Clock {
  FakeClock(this._now);
  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration d) => _now = _now.add(d);
}

class RecordingAlerts implements SeizureAlerts {
  final calls = <String>[];

  @override
  Future<void> init({void Function()? onTap}) async => calls.add('init');

  @override
  Future<bool> requestPermission() async {
    calls.add('permission');
    return true;
  }

  @override
  Future<bool> canUsePreciseAlerts() async => true;

  @override
  Future<void> requestPreciseAlerts() async {}

  @override
  Future<void> seizureStarted(Seizure seizure, EmergencyPlan plan) async =>
      calls.add('started');

  @override
  Future<void> rescueGiven(DateTime at, EmergencyPlan plan) async =>
      calls.add('rescue');

  @override
  Future<void> seizureEnded() async => calls.add('ended');
}

class FakePlatform implements PlatformBridge {
  final dialled = <String>[];
  final shared = <List<ShareableFile>>[];
  bool screenOn = false;

  @override
  Future<void> keepScreenOn(bool on) async => screenOn = on;

  @override
  Future<void> dial(String number) async => dialled.add(number);

  @override
  Future<void> openUrl(String url) async {}

  @override
  Future<bool> shareFiles(List<ShareableFile> files, {String? subject}) async {
    shared.add(files);
    return true;
  }

  @override
  Future<void> clearExportCache() async {}

  @override
  Future<Uint8List?> renderPdfPreview(Uint8List pdf) async => null;

  final printed = <String>[];

  @override
  Future<bool> printPdf(Uint8List pdf, String name) async {
    printed.add(name);
    return true;
  }
}

class FakeAuth implements DeviceAuth {
  FakeAuth({this.succeed = true});
  bool succeed;
  int prompts = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return succeed;
  }
}

class TestHarness {
  TestHarness._(
    this.services,
    this.clock,
    this.alerts,
    this.platform,
    this.launch,
    this.auth,
  );

  final AppServices services;
  final FakeClock clock;
  final RecordingAlerts alerts;
  final FakePlatform platform;
  final NoopLaunchActions launch;
  final FakeAuth auth;

  AppDatabase get db => services.db;
  SettingsStore get settings => services.settings;

  static Future<TestHarness> create({
    bool onboarded = true,
    bool appLock = false,
    DateTime? now,
    EmergencyPlan? plan,
  }) async {
    final db = openTestDatabase();
    final settings = await SettingsStore.load(db, countryCode: 'US');
    if (onboarded) await settings.setOnboardingDone(true);
    if (appLock) await settings.setAppLockEnabled(true);
    if (plan != null) await settings.setPlan(plan);
    final clock = FakeClock(now ?? DateTime(2026, 11, 18, 14, 2));
    final alerts = RecordingAlerts();
    final platform = FakePlatform();
    final launch = NoopLaunchActions();
    final auth = FakeAuth();
    final services = AppServices(
      db: db,
      settings: settings,
      alerts: alerts,
      launch: launch,
      auth: auth,
      platform: platform,
      info: const AppInfo(version: '1.0.0', buildNumber: '1'),
      clock: clock,
    );
    return TestHarness._(services, clock, alerts, platform, launch, auth);
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(buildApp());
    await settle(tester);
  }

  Widget buildApp() => SeizewellApp(services: services);

  /// Pumps a few frames; the timer screen never "settles" because its
  /// stopwatch ticks, so tests avoid pumpAndSettle.
  Future<void> settle(WidgetTester tester, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  /// Scrolls the main list until [finder] is built and visible, then taps.
  Future<void> tapInList(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await db.close();
  }
}
