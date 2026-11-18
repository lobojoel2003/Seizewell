import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seizewell/src/data/demo_data.dart';
import 'package:seizewell/src/data/queries.dart';
import 'package:seizewell/src/domain/types.dart';
import 'package:seizewell/src/services/launch_actions.dart';

import '../helpers.dart';

void main() {
  testWidgets('first run walks through onboarding to the Today screen', (
    tester,
  ) async {
    final h = await TestHarness.create(onboarded: false);
    await h.pump(tester);

    expect(find.textContaining('A calm, private'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding-next')));
    await h.settle(tester);
    await tester.tap(find.text('I have epilepsy'));
    await tester.enterText(find.byType(TextField).first, 'Robin');
    await tester.tap(find.byKey(const Key('onboarding-next')));
    await h.settle(tester);
    await tester.enterText(find.byType(TextField).at(0), 'Diazepam rectal gel');
    await tester.tap(find.byKey(const Key('onboarding-next')));
    await h.settle(tester);
    await tester.tap(find.text('Get started'));
    await h.settle(tester, 10);

    expect(find.byKey(const Key('start-seizure')), findsOneWidget);
    expect(h.settings.onboardingDone, isTrue);
    expect(h.settings.role, Reporter.patient);
    expect(h.settings.patientName, 'Robin');
    expect(h.settings.plan.rescueMedication, 'Diazepam rectal gel');
    expect(h.alerts.calls, contains('permission'));

    await h.dispose(tester);
  });

  testWidgets('app lock hides the diary but never the Start button', (
    tester,
  ) async {
    final h = await TestHarness.create(appLock: true);
    h.auth.succeed = false;
    await h.pump(tester);

    expect(find.text('Seizewell is locked'), findsOneWidget);
    expect(find.text('Diary'), findsNothing);

    await tester.tap(find.byKey(const Key('start-seizure')));
    await h.settle(tester);
    expect(find.text('Seizure in progress'), findsOneWidget);

    h.clock.advance(const Duration(seconds: 30));
    await tester.tap(find.byKey(const Key('end-seizure')));
    await h.settle(tester);
    expect(find.text('Seizure recorded'), findsOneWidget);
    expect(find.text('Add details now'), findsNothing);
    await tester.tap(find.text('Done'));
    await h.settle(tester);

    h.auth.succeed = true;
    await tester.tap(find.text('Unlock diary'));
    await h.settle(tester);
    expect(find.text('Diary'), findsOneWidget);
    expect(find.text('1 SEIZURE NEEDS DETAILS'), findsOneWidget);

    await h.dispose(tester);
  });

  testWidgets('opened over the phone lock screen only the timer is reachable', (
    tester,
  ) async {
    final h = await TestHarness.create();
    await h.pump(tester);
    h.launch.emit(
      const LaunchRequest(LaunchAction.startTimer, overLockScreen: true),
    );
    await h.settle(tester);
    expect(find.text('Seizure in progress'), findsOneWidget);
    await tester.tap(
      find.byTooltip('Back to the app. The timer keeps running.'),
    );
    await h.settle(tester);
    expect(find.text('Seizure timer'), findsOneWidget);
    expect(find.text('Diary'), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('all tabs render with six months of data', (tester) async {
    final h = await TestHarness.create();
    await loadDemoData(h.db, h.settings, today: h.clock.now());
    await h.pump(tester);

    expect(find.text('1 SEIZURE NEEDS DETAILS'), findsOneWidget);
    for (final tab in ['Diary', 'Insights', 'Meds', 'More', 'Today']) {
      await tester.tap(find.text(tab).last);
      await h.settle(tester);
      expect(tester.takeException(), isNull, reason: tab);
    }
    await tester.tap(find.text('Insights').last);
    await h.settle(tester);
    expect(find.text('Per 30 days'), findsOneWidget);
    await h.tapInList(tester, find.text('BY SEIZURE TYPE'));

    await h.dispose(tester);
  });

  testWidgets('a past seizure can be logged from the diary', (tester) async {
    final h = await TestHarness.create();
    await h.pump(tester);
    await tester.tap(find.text('Diary'));
    await h.settle(tester);
    await tester.tap(find.text('Log seizure'));
    await h.settle(tester);

    await tester.enterText(find.byKey(const Key('duration-minutes')), '2');
    await tester.enterText(find.byKey(const Key('duration-seconds')), '30');
    await h.tapInList(tester, find.text('Tonic-clonic'));
    await tester.tap(find.byKey(const Key('save-seizure')));
    await h.settle(tester);

    final entry = (await h.db.allSeizures()).single;
    expect(entry.duration, const Duration(minutes: 2, seconds: 30));
    expect(entry.seizure.type, SeizureType.tonicClonic);
    expect(find.text('Generalized tonic-clonic'), findsOneWidget);

    await h.dispose(tester);
  });
}
