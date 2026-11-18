import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quick_actions/quick_actions.dart';

enum LaunchAction {
  startTimer('start_timer'),
  logSeizure('log_seizure'),
  logSleep('log_sleep');

  const LaunchAction(this.id);
  final String id;

  static LaunchAction? fromId(String? id) =>
      LaunchAction.values.where((a) => a.id == id).firstOrNull;
}

class LaunchRequest {
  const LaunchRequest(this.action, {this.overLockScreen = false});

  final LaunchAction action;

  /// True when Android opened the timer on top of the lock screen (Quick
  /// Settings tile while the phone is locked). Only the timer may be shown.
  final bool overLockScreen;
}

/// Requests to open Seizewell at a specific place, coming from the home
/// screen widget, the Quick Settings tile (Android), and the app icon's
/// long-press shortcuts (Android and iOS).
abstract interface class LaunchActions {
  /// Buffered until the app subscribes, so a cold start from the widget is
  /// never lost.
  Stream<LaunchRequest> get requests;
  Future<void> init();

  /// Asks Android to dismiss the keyguard (shows the PIN/biometric prompt).
  Future<bool> requestDeviceUnlock();

  /// Whether the phone itself is currently locked.
  Future<bool> isDeviceLocked();
}

class NoopLaunchActions implements LaunchActions {
  final _controller = StreamController<LaunchRequest>();

  void emit(LaunchRequest r) => _controller.add(r);

  @override
  Stream<LaunchRequest> get requests => _controller.stream;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestDeviceUnlock() async => true;

  @override
  Future<bool> isDeviceLocked() async => false;
}

class PlatformLaunchActions implements LaunchActions {
  static const _channel = MethodChannel(
    'io.github.lobojoel2003.seizewell/launch',
  );

  final _controller = StreamController<LaunchRequest>();
  final _quickActions = const QuickActions();

  @override
  Stream<LaunchRequest> get requests => _controller.stream;

  void _emit(Object? args) {
    if (args is! Map) return;
    final action = LaunchAction.fromId(args['action'] as String?);
    if (action == null) return;
    _controller.add(
      LaunchRequest(action, overLockScreen: args['overLockScreen'] == true),
    );
  }

  @override
  Future<void> init() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onAction') _emit(call.arguments);
    });
    try {
      _emit(
        await _channel.invokeMethod<Map<Object?, Object?>>('initialAction'),
      );
    } on MissingPluginException {
      // iOS has no native launch channel; quick actions cover it.
    } on PlatformException catch (e) {
      debugPrint('LaunchActions: $e');
    }

    try {
      await _quickActions.initialize((type) => _emit({'action': type}));
      await _quickActions.setShortcutItems(const [
        ShortcutItem(
          type: 'start_timer',
          localizedTitle: 'Start seizure timer',
          icon: 'ic_shortcut_timer',
        ),
        ShortcutItem(
          type: 'log_seizure',
          localizedTitle: 'Log a past seizure',
          icon: 'ic_shortcut_log',
        ),
        ShortcutItem(
          type: 'log_sleep',
          localizedTitle: 'Log sleep',
          icon: 'ic_shortcut_sleep',
        ),
      ]);
    } on Object catch (e) {
      debugPrint('Quick actions unavailable: $e');
    }
  }

  @override
  Future<bool> requestDeviceUnlock() async {
    try {
      return await _channel.invokeMethod<bool>('requestUnlock') ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> isDeviceLocked() async {
    try {
      return await _channel.invokeMethod<bool>('isDeviceLocked') ?? false;
    } on Object {
      return false;
    }
  }
}
