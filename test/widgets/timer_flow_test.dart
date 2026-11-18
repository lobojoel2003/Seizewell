import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seizewell/src/data/queries.dart';
import 'package:seizewell/src/domain/emergency_plan.dart';
import 'package:seizewell/src/domain/types.dart';
import 'package:seizewell/src/services/launch_actions.dart';

import '../helpers.dart';

void main() {
  const plan = EmergencyPlan(
    rescueMedication: 'Midazolam nasal spray',
    rescueDose: '5 mg',
    emergencyNumber: '911',
    contacts: [EmergencyContact(name: 'Jordan', phone: '+1 555 0100')],
  );

  testWidgets('one tap starts the timer; it escalates at 5 minutes', (
    tester,
  ) async {
    final h = await TestHarness.create(plan: plan);
    await h.pump(tester);

    await tester.tap(find.byKey(const Key('start-seizure')));
    await h.settle(tester);

    expect(find.text('Seizure in progress'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('While you time it'), findsOneWidget);
    expect(h.alerts.calls, ['init', 'sync']);
    expect(h.platform.screenOn, isTrue);
    expect(await h.db.activeSeizure(), isNotNull);

    h.clock.advance(const Duration(minutes: 1, seconds: 7));
    await h.settle(tester, 3);
    expect(find.text('01:07'), findsOneWidget);

    h.clock.advance(const Duration(minutes: 4));
    await h.settle(tester, 3);
    expect(find.text('05:07'), findsOneWidget);
    expect(find.text('Follow the emergency plan'), findsOneWidget);
    expect(find.textContaining('Midazolam nasal spray — 5 mg'), findsOneWidget);

    await tester.tap(find.byKey(const Key('rescue-given')));
    await h.settle(tester);
    expect(find.textContaining('Rescue given'), findsWidgets);
    expect(h.alerts.calls.last, 'sync:rescue');

    await tester.tap(find.text('Call 911'));
    expect(h.platform.dialled, ['911']);

    h.clock.advance(const Duration(minutes: 10));
    await h.settle(tester, 3);
    expect(find.text('Still seizing? Call 911 now.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('end-seizure')));
    await h.settle(tester);
    expect(find.text('Seizure recorded'), findsOneWidget);
    expect(find.text('15 min 7 s'), findsOneWidget);
    expect(h.alerts.calls, contains('ended'));
    expect(await h.db.activeSeizure(), isNull);

    final saved = (await h.db.allSeizures()).single;
    expect(saved.duration, const Duration(minutes: 15, seconds: 7));
    expect(saved.seizure.rescueMedication, 'Midazolam nasal spray');

    await h.dispose(tester);
  });

  testWidgets('details can be added right after the timer', (tester) async {
    final h = await TestHarness.create();
    await h.pump(tester);

    await tester.tap(find.byKey(const Key('start-seizure')));
    await h.settle(tester);
    h.clock.advance(const Duration(seconds: 48));
    await tester.tap(find.byKey(const Key('end-seizure')));
    await h.settle(tester);

    await tester.tap(find.text('Add details now'));
    await h.settle(tester);
    expect(find.text('Seizure details'), findsOneWidget);

    await h.tapInList(tester, find.text('Absence'));
    await h.tapInList(tester, find.text('Stress'));
    await tester.tap(find.byKey(const Key('save-seizure')));
    await h.settle(tester);

    final entry = (await h.db.allSeizures()).single;
    expect(entry.seizure.type, SeizureType.absence);
    expect(entry.seizure.detailsCompleted, isTrue);
    expect(entry.triggers.map((t) => t.name), ['Stress']);
    expect(entry.duration, const Duration(seconds: 48));

    await h.dispose(tester);
  });

  testWidgets('started-earlier chips move the start back', (tester) async {
    final h = await TestHarness.create();
    await h.pump(tester);
    await tester.tap(find.byKey(const Key('start-seizure')));
    await h.settle(tester);

    await tester.tap(find.text('−30 s'));
    await h.settle(tester);
    expect(find.text('00:30'), findsOneWidget);

    await h.dispose(tester);
  });

  testWidgets('resume undoes an early "Seizure ended"', (tester) async {
    final h = await TestHarness.create();
    await h.pump(tester);
    await tester.tap(find.byKey(const Key('start-seizure')));
    await h.settle(tester);
    h.clock.advance(const Duration(seconds: 20));
    await tester.tap(find.byKey(const Key('end-seizure')));
    await h.settle(tester);

    await tester.tap(find.text('Not over — resume the timer'));
    await h.settle(tester);
    expect(find.text('Seizure in progress'), findsOneWidget);
    expect(await h.db.activeSeizure(), isNotNull);

    await h.dispose(tester);
  });

  testWidgets('home screen widget / tile / shortcut opens the timer', (
    tester,
  ) async {
    final h = await TestHarness.create();
    await h.pump(tester);
    h.launch.emit(const LaunchRequest(LaunchAction.startTimer));
    await h.settle(tester);
    expect(find.text('Seizure in progress'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('a running seizure re-opens the timer on launch', (tester) async {
    final h = await TestHarness.create();
    await h.db.startSeizure(
      at: h.clock.now().subtract(const Duration(seconds: 90)),
      loggedBy: Reporter.caregiver,
    );
    await h.pump(tester);
    expect(find.text('Seizure in progress'), findsOneWidget);
    expect(find.text('01:30'), findsOneWidget);
    await h.dispose(tester);
  });
}
