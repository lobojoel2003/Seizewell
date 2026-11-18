import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/brand.dart';
import '../core/format.dart';
import '../data/database.dart';
import '../domain/emergency_plan.dart';

/// Keeps the person timing a seizure informed even when they switch to the
/// phone app to call for help: a live stopwatch notification, and alerts at
/// the emergency-plan thresholds.
abstract interface class SeizureAlerts {
  Future<void> init({void Function()? onTap});
  Future<bool> requestPermission();
  Future<bool> canUsePreciseAlerts();
  Future<void> requestPreciseAlerts();
  Future<void> seizureStarted(Seizure seizure, EmergencyPlan plan);
  Future<void> rescueGiven(DateTime at, EmergencyPlan plan);
  Future<void> seizureEnded();
}

class NoopSeizureAlerts implements SeizureAlerts {
  const NoopSeizureAlerts();

  @override
  Future<void> init({void Function()? onTap}) async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> canUsePreciseAlerts() async => true;

  @override
  Future<void> requestPreciseAlerts() async {}

  @override
  Future<void> seizureStarted(Seizure seizure, EmergencyPlan plan) async {}

  @override
  Future<void> rescueGiven(DateTime at, EmergencyPlan plan) async {}

  @override
  Future<void> seizureEnded() async {}
}

class LocalNotificationAlerts implements SeizureAlerts {
  LocalNotificationAlerts([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _timerId = 1001;
  static const _thresholdId = 1002;
  static const _rescueId = 1003;

  static const _timerChannel = AndroidNotificationDetails(
    'seizure_timer',
    'Seizure timer',
    channelDescription: 'Shows the running seizure stopwatch.',
    importance: Importance.low,
    priority: Priority.low,
    playSound: false,
    enableVibration: false,
  );

  static const _alertChannelId = 'seizure_alerts';
  static const _alertChannelName = 'Emergency plan alerts';
  static const _alertChannelDescription =
      'Alerts when a seizure reaches the time in your emergency plan.';

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> init({void Function()? onTap}) async {
    await _guard(() async {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_seizewell'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (_) => onTap?.call(),
      );
    });
  }

  @override
  Future<bool> requestPermission() async {
    return await _guard(() async {
          if (Platform.isAndroid) {
            return await _android?.requestNotificationsPermission() ?? false;
          }
          if (Platform.isIOS) {
            return await _plugin
                    .resolvePlatformSpecificImplementation<
                      IOSFlutterLocalNotificationsPlugin
                    >()
                    ?.requestPermissions(alert: true, sound: true) ??
                false;
          }
          return false;
        }) ??
        false;
  }

  @override
  Future<bool> canUsePreciseAlerts() async {
    if (!Platform.isAndroid) return true;
    return await _guard(() async {
          return await _android?.canScheduleExactNotifications() ?? true;
        }) ??
        true;
  }

  @override
  Future<void> requestPreciseAlerts() async {
    if (!Platform.isAndroid) return;
    await _guard(() async => _android?.requestExactAlarmsPermission());
  }

  @override
  Future<void> seizureStarted(Seizure seizure, EmergencyPlan plan) async {
    await _guard(() async {
      await _plugin.cancel(id: _rescueId);
      await _plugin.show(
        id: _timerId,
        title: 'Seizure timer running',
        body:
            'Started at ${formatTime(seizure.startedAt)}. '
            'Alert at ${formatStopwatch(plan.alertAfter)}. Tap to open.',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _timerChannel.channelId,
            _timerChannel.channelName,
            channelDescription: _timerChannel.channelDescription,
            importance: _timerChannel.importance,
            priority: _timerChannel.priority,
            playSound: false,
            enableVibration: false,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            requestPromotedOngoing: true,
            usesChronometer: true,
            when: seizure.startedAt.millisecondsSinceEpoch,
            category: AndroidNotificationCategory.stopwatch,
            visibility: NotificationVisibility.public,
            color: const Color(Brand.violet),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: false,
            presentBanner: false,
            presentList: true,
            presentSound: false,
          ),
        ),
      );
      final at = seizure.startedAt.add(plan.alertAfter);
      final rescue = plan.hasRescueMedication
          ? 'Give ${plan.rescueMedication}'
                '${plan.rescueDose.isEmpty ? '' : ' (${plan.rescueDose})'} '
                'if prescribed, and call ${plan.emergencyNumber}.'
          : 'Follow your emergency plan and call ${plan.emergencyNumber}.';
      await _schedule(
        _thresholdId,
        at,
        'Seizure has lasted ${formatDuration(plan.alertAfter)}',
        rescue,
      );
    });
  }

  @override
  Future<void> rescueGiven(DateTime at, EmergencyPlan plan) async {
    await _guard(() async {
      await _plugin.cancel(id: _thresholdId);
      await _schedule(
        _rescueId,
        at.add(plan.callAfterRescue),
        'Rescue medication given ${formatDuration(plan.callAfterRescue)} ago',
        'If the seizure has not stopped, call ${plan.emergencyNumber} now.',
      );
    });
  }

  @override
  Future<void> seizureEnded() async {
    await _guard(() async {
      await _plugin.cancel(id: _timerId);
      await _plugin.cancel(id: _thresholdId);
      await _plugin.cancel(id: _rescueId);
    });
  }

  Future<void> _schedule(int id, DateTime at, String title, String body) async {
    if (!at.isAfter(DateTime.now())) return;
    final precise = await canUsePreciseAlerts();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
      androidScheduleMode: precise
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _alertChannelId,
          _alertChannelName,
          channelDescription: _alertChannelDescription,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          color: Color(Brand.alert),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }

  /// Notifications must never break the timer itself.
  Future<T?> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on Object catch (e, st) {
      debugPrint('SeizureAlerts: $e\n$st');
      return null;
    }
  }
}
