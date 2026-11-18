// Regression tests for the emergency path: the timer must never vanish,
// duplicate, or silently lose its alarms.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seizewell/src/data/queries.dart';
import 'package:seizewell/src/domain/emergency_plan.dart';
import 'package:seizewell/src/domain/types.dart';
import 'package:seizewell/src/services/launch_actions.dart';
import 'package:seizewell/src/ui/timer/active_seizure_screen.dart';

import '../helpers.dart';

void main() {
  const plan = EmergencyPlan(rescueMedication: 'Midazolam', rescueDose: '5 mg');

  testWidgets('the app lock never hides a running timer', (tester) async {
    final h = await TestHarness.create(appLock: true, plan: plan);
    h.services.lock.unlock();
    await h.pump(tester);

    // A diary screen is open underneath when the timer starts.
    await tester.tap(find.text('Diary'));
    await h.settle(tester);
    await tester.tap(find.text('Log seizure'));
    await h.settle(tester);
    h.launch.emit(const LaunchRequest(LaunchAction.startTimer));
    await h.settle(tester);
    expect(find.byType(ActiveSeizureScreen), findsOneWidget);

    // Back from >60 s in the phone app: the lock engages.
    h.services.lock.lock();
    await h.settle(tester, 10);
    expect(find.byType(ActiveSeizureScreen), findsOneWidget);
    expect(find.text('Seizure in progress'), findsOneWidget);

    // Closing the timer shows the lock screen, not the diary editor.
    await tester.tap(
      find.byTooltip('Back to the app. The timer keeps running.'),
    );
    await h.settle(tester, 10);
    expect(find.text('Seizewell is locked'), findsOneWidget);
    expect(find.text('Log a seizure'), findsNothing);

    await h.dispose(tester);
  });

  testWidgets('re-opening the timer keeps the post-rescue alarm', (
    tester,
  ) async {
    final h = await TestHarness.create(plan: plan);
    await h.pump(tester);
    await tester.tap(find.byKey(const Key('start-seizure')));
    await h.settle(tester);
    h.clock.advance(const Duration(minutes: 5));
    await tester.tap(find.byKey(const Key('rescue-given')));
    await h.settle(tester);
    expect(h.alerts.calls.last, 'sync:rescue');

    // Leave the timer, then come back from the widget and the Start button.
    await tester.tap(
      find.byTooltip('Back to the app. The timer keeps running.'),
    );
    await h.settle(tester);
    h.launch.emit(const LaunchRequest(LaunchAction.startTimer));
    await h.settle(tester);
    await tester.tap(
      find.byTooltip('Back to the app. The timer keeps running.'),
    );
    await h.settle(tester);
    await tester.tap(find.byKey(const Key('start-seizure')));
    await h.settle(tester);

    expect(h.alerts.calls.where((c) => c == 'sync'), hasLength(1));
    expect(h.alerts.calls.last, 'sync:rescue');
    expect((await h.db.activeSeizure())!.rescueGivenAt, isNotNull);

    await h.dispose(tester);
  });

  testWidgets('a double tap on "Rescue given" does not undo it', (
    tester,
  ) async {
    final h = await TestHarness.create(plan: plan);
    await h.pump(tester);
    await tester.tap(find.byKey(const Key('start-seizure')));
    await h.settle(tester);

    await tester.tap(find.byKey(const Key('rescue-given')));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.byKey(const Key('rescue-given')));
    await h.settle(tester);

    // The second tap only asks for confirmation.
    expect(find.text('Undo rescue medication?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await h.settle(tester);
    expect((await h.db.activeSeizure())!.rescueGivenAt, isNotNull);

    // Undo still works deliberately.
    await tester.tap(find.byKey(const Key('rescue-given')));
    await h.settle(tester);
    await tester.tap(find.text('Undo'));
    await h.settle(tester);
    expect((await h.db.activeSeizure())!.rescueGivenAt, isNull);
    expect(h.alerts.calls.last, 'sync');

    await h.dispose(tester);
  });

  testWidgets('a widget launch during a running seizure opens one timer', (
    tester,
  ) async {
    final h = await TestHarness.create();
    await h.db.startSeizure(
      at: h.clock.now().subtract(const Duration(seconds: 30)),
      loggedBy: Reporter.caregiver,
    );
    // Cold start: the launch request is already waiting.
    h.launch.emit(const LaunchRequest(LaunchAction.startTimer));
    await h.pump(tester);
    await h.settle(tester);
    expect(find.byType(ActiveSeizureScreen), findsOneWidget);
    expect(h.platform.screenOn, isTrue);

    h.clock.advance(const Duration(seconds: 10));
    await tester.tap(find.byKey(const Key('end-seizure')));
    await h.settle(tester);
    expect(find.text('Seizure recorded'), findsOneWidget);
    expect(find.byType(ActiveSeizureScreen), findsNothing);
    expect(h.platform.screenOn, isFalse);
    expect(
      (await h.db.allSeizures()).single.duration,
      const Duration(seconds: 40),
    );

    await h.dispose(tester);
  });

  testWidgets('no fingerprint prompt over a running timer', (tester) async {
    final h = await TestHarness.create(appLock: true);
    await h.db.startSeizure(at: h.clock.now(), loggedBy: Reporter.caregiver);
    await h.pump(tester);
    await h.settle(tester, 10);
    expect(find.byType(ActiveSeizureScreen), findsOneWidget);
    expect(h.auth.prompts, 0);
    await h.dispose(tester);
  });

  testWidgets('the lock screen still offers the prompt when idle', (
    tester,
  ) async {
    final h = await TestHarness.create(appLock: true);
    h.auth.succeed = false;
    await h.pump(tester);
    await h.settle(tester, 10);
    expect(h.auth.prompts, 1);
    await h.dispose(tester);
  });

  testWidgets('deleting everything clears pending alarms', (tester) async {
    final h = await TestHarness.create();
    await h.pump(tester);
    await tester.tap(find.byKey(const Key('start-seizure')));
    await h.settle(tester);
    await tester.tap(
      find.byTooltip('Back to the app. The timer keeps running.'),
    );
    await h.settle(tester);
    await tester.tap(find.text('More'));
    await h.settle(tester);
    await h.tapInList(tester, find.text('Delete all data'));
    await h.settle(tester);
    await tester.tap(find.text('Delete everything'));
    await h.settle(tester);
    expect(h.alerts.calls.last, 'ended');
    expect(await h.db.activeSeizure(), isNull);
    await h.dispose(tester);
  });
}
