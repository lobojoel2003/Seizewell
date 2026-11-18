import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'app_services.dart';
import 'data/database.dart';
import 'data/queries.dart';
import 'services/launch_actions.dart';
import 'ui/actions.dart';
import 'ui/lock/lock_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/seizure/seizure_editor_screen.dart';
import 'ui/shell.dart';
import 'ui/sleep/sleep_sheet.dart';
import 'ui/theme.dart';

class SeizewellApp extends StatefulWidget {
  const SeizewellApp({super.key, required this.services});

  final AppServices services;

  @override
  State<SeizewellApp> createState() => _SeizewellAppState();
}

class _SeizewellAppState extends State<SeizewellApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<LaunchRequest>? _launchSub;
  late final AppLifecycleListener _lifecycle;
  DateTime? _hiddenAt;

  /// How long the app may sit in the background before the app lock
  /// engages again.
  static const lockGrace = Duration(seconds: 60);

  AppServices get _s => widget.services;

  @override
  void initState() {
    super.initState();
    _launchSub = _s.launch.requests.listen(_onLaunch);
    _lifecycle = AppLifecycleListener(onHide: _onHide, onShow: _onShow);
    _s.lock.addListener(_onLockChanged);
    _s.settings.addListener(_onSettingsChanged);
    unawaited(_s.alerts.init(onTap: _openActiveTimer));
    unawaited(_s.launch.init());
    WidgetsBinding.instance.addPostFrameCallback((_) => _openActiveTimer());
  }

  @override
  void dispose() {
    _launchSub?.cancel();
    _lifecycle.dispose();
    _s.lock.removeListener(_onLockChanged);
    _s.settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  NavigatorState? get _nav => _navigatorKey.currentState;

  Future<void> _openActiveTimer() async {
    final active = await _s.db.activeSeizure();
    final nav = _nav;
    if (active != null && nav != null) openTimer(nav);
  }

  void _onSettingsChanged() {
    // Turning the lock off while locked (e.g. after "delete everything").
    if (!_s.settings.appLockEnabled && !_s.lock.overLockScreen) {
      _s.lock.unlock();
    }
  }

  Future<void> _onLaunch(LaunchRequest request) async {
    var nav = _nav;
    if (nav == null) {
      await WidgetsBinding.instance.endOfFrame;
      nav = _nav;
      if (nav == null) return;
    }
    if (request.overLockScreen) _s.lock.enterLockScreenMode();
    switch (request.action) {
      case LaunchAction.startTimer:
        await startSeizureTimer(_s, nav);
      case LaunchAction.logSeizure:
        if (!_s.lock.locked) await nav.push(SeizureEditorScreen.route());
      case LaunchAction.logSleep:
        final context = nav.overlay?.context;
        if (!_s.lock.locked && context != null && context.mounted) {
          await showSleepSheet(context, night: _s.clock.now());
        }
    }
  }

  void _onHide() => _hiddenAt = _s.clock.now();

  Future<void> _onShow() async {
    final hiddenAt = _hiddenAt;
    _hiddenAt = null;
    if (_s.lock.overLockScreen && !await _s.launch.isDeviceLocked()) {
      _s.lock.leaveLockScreenMode();
    }
    if (_s.settings.appLockEnabled &&
        hiddenAt != null &&
        _s.clock.now().difference(hiddenAt) > lockGrace) {
      _s.lock.lock();
    }
  }

  Future<void> _onLockChanged() async {
    if (!_s.lock.locked) return;
    // Hide whatever diary screens were open; keep a running timer visible.
    final nav = _nav;
    if (nav == null) return;
    nav.popUntil((route) => route.isFirst);
    final Seizure? active = await _s.db.activeSeizure();
    if (active != null && _nav != null) openTimer(_nav!);
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: _s,
      child: ListenableBuilder(
        listenable: _s.settings,
        builder: (context, _) => MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Seizewell',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: toThemeMode(_s.settings.themeMode),
          home: const _RootGate(),
        ),
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    return ListenableBuilder(
      listenable: Listenable.merge([s.settings, s.lock]),
      builder: (context, _) {
        final Widget child;
        if (!s.settings.onboardingDone && !s.lock.overLockScreen) {
          child = const OnboardingScreen();
        } else if (s.lock.locked) {
          child = const LockScreen();
        } else {
          child = const AppShell();
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(key: ValueKey(child.runtimeType), child: child),
        );
      },
    );
  }
}
