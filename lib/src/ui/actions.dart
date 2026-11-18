import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../app_services.dart';
import '../data/queries.dart';
import 'timer/active_seizure_screen.dart';

/// Starts timing a seizure (or re-opens the running one) and shows the timer.
/// This is the one-tap path used by the big button, the lock screen, the
/// home screen widget, the Quick Settings tile and the app shortcut.
Future<void> startSeizureTimer(
  AppServices services,
  NavigatorState navigator,
) async {
  unawaited(HapticFeedback.heavyImpact());
  final seizure = await services.db.startSeizure(
    at: services.clock.now(),
    loggedBy: services.settings.role,
  );
  unawaited(services.alerts.seizureStarted(seizure, services.settings.plan));
  openTimer(navigator);
}

/// Shows the timer screen unless it is already visible.
void openTimer(NavigatorState navigator) {
  if (ActiveSeizureScreen.isOpen) return;
  navigator.push(ActiveSeizureScreen.route());
}
