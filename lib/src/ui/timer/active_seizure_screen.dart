import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../../domain/emergency_plan.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'seizure_ended_screen.dart';

/// Full-screen stopwatch for a seizure in progress.
///
/// Designed for a frightening moment: one huge number, one huge button,
/// and the family's own emergency plan once the seizure runs long.
class ActiveSeizureScreen extends StatefulWidget {
  const ActiveSeizureScreen({super.key});

  static int _openCount = 0;
  static bool get isOpen => _openCount > 0;

  static Route<void> route() => PageRouteBuilder<void>(
    settings: const RouteSettings(name: '/timer'),
    fullscreenDialog: true,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, _, _) => const ActiveSeizureScreen(),
    transitionsBuilder: (_, animation, _, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    ),
  );

  @override
  State<ActiveSeizureScreen> createState() => _ActiveSeizureScreenState();
}

enum _Phase { calm, alert, rescue, callNow }

class _ActiveSeizureScreenState extends State<ActiveSeizureScreen> {
  late final AppServices _s;
  StreamSubscription<Seizure?>? _sub;
  Timer? _ticker;
  Seizure? _seizure;
  bool _loaded = false;
  bool _ending = false;
  _Phase? _lastPhase;

  @override
  void initState() {
    super.initState();
    ActiveSeizureScreen._openCount++;
    _s = context.services;
    unawaited(_s.platform.keepScreenOn(true));
    _sub = _s.db.watchActiveSeizure().listen((s) {
      if (!mounted) return;
      if (s == null && _loaded && !_ending) {
        Navigator.of(context).maybePop();
        return;
      }
      setState(() {
        _seizure = s;
        _loaded = true;
      });
    });
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    ActiveSeizureScreen._openCount--;
    _ticker?.cancel();
    _sub?.cancel();
    unawaited(_s.platform.keepScreenOn(false));
    super.dispose();
  }

  EmergencyPlan get _plan => _s.settings.plan;

  _Phase _phase(Seizure s, DateTime now) {
    final rescueAt = s.rescueGivenAt;
    if (rescueAt != null) {
      return now.difference(rescueAt) >= _plan.callAfterRescue
          ? _Phase.callNow
          : _Phase.rescue;
    }
    return now.difference(s.startedAt) >= _plan.alertAfter
        ? _Phase.alert
        : _Phase.calm;
  }

  /// Red once the seizure passes the plan's threshold, and whenever it is
  /// time to call for help.
  bool _isDanger(Seizure s, DateTime now, _Phase phase) =>
      phase == _Phase.callNow ||
      now.difference(s.startedAt) >= _plan.alertAfter;

  void _onPhaseChange(_Phase phase) {
    if (_lastPhase == phase) return;
    final escalated =
        _lastPhase != null &&
        (phase == _Phase.alert || phase == _Phase.callNow);
    _lastPhase = phase;
    if (escalated) {
      unawaited(_buzz());
    }
  }

  Future<void> _buzz() async {
    for (var i = 0; i < 3; i++) {
      await HapticFeedback.heavyImpact();
      await SystemSound.play(SystemSoundType.alert);
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
  }

  Future<void> _end() async {
    final s = _seizure;
    if (s == null || _ending) return;
    setState(() => _ending = true);
    unawaited(HapticFeedback.mediumImpact());
    await _s.db.endSeizure(s.id, _s.clock.now());
    unawaited(_s.alerts.seizureEnded());
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(SeizureEndedScreen.route(s.id));
  }

  Future<void> _rescue() async {
    final s = _seizure;
    if (s == null) return;
    final now = _s.clock.now();
    if (s.rescueGivenAt != null) {
      await _s.db.clearRescue(s.id);
      unawaited(_s.alerts.seizureStarted(s, _plan));
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    await _s.db.recordRescue(
      s.id,
      now,
      _plan.hasRescueMedication ? _plan.rescueMedication : null,
    );
    unawaited(_s.alerts.rescueGiven(now, _plan));
  }

  Future<void> _startedEarlier(Duration by) async {
    final s = _seizure;
    if (s == null) return;
    final updated = await _s.db.moveSeizureStart(
      s.id,
      s.startedAt.subtract(by),
    );
    unawaited(_s.alerts.seizureStarted(updated, _plan));
  }

  Future<void> _discard() async {
    final s = _seizure;
    if (s == null) return;
    final ok = await confirm(
      context,
      title: 'Discard this timer?',
      message:
          'Use this if the timer was started by mistake. Nothing will be '
          'saved.',
      confirmLabel: 'Discard',
      destructive: true,
    );
    if (!ok || !mounted) return;
    _ending = true;
    await _s.db.deleteSeizure(s.id);
    unawaited(_s.alerts.seizureEnded());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = _seizure;
    final now = _s.clock.now();
    final phase = s == null ? _Phase.calm : _phase(s, now);
    if (s != null) _onPhaseChange(phase);
    final danger = s != null && _isDanger(s, now, phase);
    final colors = danger
        ? const [alertDeep, Color(0xFF8E1616)]
        : const [brandNight, brandDeep];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: s == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _body(context, s, now, phase),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, Seizure s, DateTime now, _Phase phase) {
    final elapsed = now.difference(s.startedAt);
    final plan = _plan;
    final theme = Theme.of(context);
    final danger = _isDanger(s, now, phase);
    final progress = elapsed.inMilliseconds / plan.alertAfter.inMilliseconds;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back to the app. The timer keeps running.',
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Text(
                  danger
                      ? 'Over ${formatDuration(plan.alertAfter)}'
                      : 'Seizure in progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'More',
                iconColor: Colors.white,
                onSelected: (v) {
                  if (v == 'discard') _discard();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'discard',
                    child: Text('Started by mistake — discard'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              Center(
                child: _Dial(
                  progress: progress,
                  danger: danger,
                  label: formatStopwatch(elapsed),
                  caption: 'Started ${formatTime(s.startedAt)}',
                ),
              ),
              if (phase == _Phase.calm && elapsed < const Duration(minutes: 2))
                _StartedEarlier(onShift: _startedEarlier),
              const SizedBox(height: 16),
              _ActionRow(
                plan: plan,
                rescueGiven: s.rescueGivenAt != null,
                emphasiseRescue: phase == _Phase.alert,
                emphasiseCall: phase == _Phase.callNow,
                onRescue: _rescue,
                onDial: (n) => _s.platform.dial(n),
              ),
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: _StatusCard(
                  phase: phase,
                  plan: plan,
                  seizure: s,
                  now: now,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 76,
            child: FilledButton.icon(
              key: const Key('end-seizure'),
              onPressed: _ending ? null : _end,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: danger ? alertDeep : brandDeep,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(Icons.stop_circle_outlined, size: 30),
              label: const Text('Seizure ended'),
            ),
          ),
        ),
      ],
    );
  }
}

class _Dial extends StatelessWidget {
  const _Dial({
    required this.progress,
    required this.danger,
    required this.label,
    required this.caption,
  });

  final double progress;
  final bool danger;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final size = math.min(
      280.0,
      math.min(screen.width - 72, screen.height * 0.34),
    );
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, danger: danger),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: 'Elapsed $label',
                excludeSemantics: true,
                child: FittedBox(
                  child: Text(
                    label,
                    key: const Key('stopwatch'),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: size * 0.26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFeatures: tabular,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                caption,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.danger});

  final double progress;
  final bool danger;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2 - stroke;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius, track);

    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: danger
            ? const [Color(0xFFFFB4AB), Colors.white]
            : const [Color(0xFF9D8BFF), Color(0xFFE6DEFF)],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      danger ? 2 * math.pi : sweep,
      false,
      arc,
    );

    if (!danger && progress > 0) {
      final angle = -math.pi / 2 + sweep;
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        stroke / 2 + 3,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.danger != danger;
}

class _StartedEarlier extends StatelessWidget {
  const _StartedEarlier({required this.onShift});

  final ValueChanged<Duration> onShift;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, Duration d) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => onShift(d),
        child: Text(label),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text(
              'Started earlier?',
              style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
            ),
          ),
          chip('−15 s', const Duration(seconds: 15)),
          chip('−30 s', const Duration(seconds: 30)),
          chip('−1 min', const Duration(minutes: 1)),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.phase,
    required this.plan,
    required this.seizure,
    required this.now,
  });

  final _Phase phase;
  final EmergencyPlan plan;
  final Seizure seizure;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = theme.textTheme.titleMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );
    final body = theme.textTheme.bodyLarge?.copyWith(
      color: Colors.white.withValues(alpha: 0.88),
      height: 1.4,
    );
    final rescueLine = plan.hasRescueMedication
        ? '${plan.rescueMedication}'
              '${plan.rescueDose.isEmpty ? '' : ' — ${plan.rescueDose}'}'
        : null;

    final children = <Widget>[];
    switch (phase) {
      case _Phase.calm:
        children.addAll([
          Text('While you time it', style: title),
          const SizedBox(height: 10),
          for (final step in firstAidSteps)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7, right: 10),
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: Colors.white70,
                    ),
                  ),
                  Expanded(child: Text(step, style: body)),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'At ${formatStopwatch(plan.alertAfter)} the screen turns red '
            'and shows your emergency plan.',
            style: body?.copyWith(color: Colors.white60, fontSize: 14),
          ),
        ]);
      case _Phase.alert:
        children.addAll([
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Follow the emergency plan',
                  style: title?.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (rescueLine != null)
            Text('Give rescue medication: $rescueLine', style: body)
          else
            Text(
              'No rescue medication is set up. Call '
              '${plan.emergencyNumber} if the seizure does not stop.',
              style: body,
            ),
          if (plan.instructions.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(plan.instructions.trim(), style: body),
          ],
        ]);
      case _Phase.rescue:
      case _Phase.callNow:
        final given = seizure.rescueGivenAt!;
        final since = now.difference(given);
        final callAt = given.add(plan.callAfterRescue);
        children.addAll([
          Row(
            children: [
              const Icon(Icons.medication_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rescue given ${formatStopwatch(since)} ago',
                  style: title,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            phase == _Phase.callNow
                ? 'Still seizing? Call ${plan.emergencyNumber} now.'
                : 'If still seizing at ${formatTime(callAt)}, call '
                      '${plan.emergencyNumber}.',
            style: body?.copyWith(
              fontWeight: phase == _Phase.callNow ? FontWeight.w700 : null,
              fontSize: phase == _Phase.callNow ? 19 : null,
              color: Colors.white,
            ),
          ),
          if (plan.instructions.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(plan.instructions.trim(), style: body),
          ],
        ]);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.plan,
    required this.rescueGiven,
    required this.emphasiseRescue,
    required this.emphasiseCall,
    required this.onRescue,
    required this.onDial,
  });

  final EmergencyPlan plan;
  final bool rescueGiven;
  final bool emphasiseRescue;
  final bool emphasiseCall;
  final VoidCallback onRescue;
  final ValueChanged<String> onDial;

  @override
  Widget build(BuildContext context) {
    ButtonStyle style({required bool strong}) => FilledButton.styleFrom(
      backgroundColor: strong
          ? Colors.white
          : Colors.white.withValues(alpha: 0.12),
      foregroundColor: strong ? alertDeep : Colors.white,
      minimumSize: const Size(0, 60),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: const Key('rescue-given'),
                style: style(strong: emphasiseRescue),
                onPressed: onRescue,
                icon: Icon(
                  rescueGiven ? Icons.undo_rounded : Icons.medication_rounded,
                ),
                label: Text(rescueGiven ? 'Undo rescue' : 'Rescue given'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                style: style(strong: emphasiseCall),
                onPressed: () => onDial(plan.emergencyNumber),
                icon: const Icon(Icons.call_rounded),
                label: Text('Call ${plan.emergencyNumber}'),
              ),
            ),
          ],
        ),
        for (final c in plan.contacts.where((c) => c.phone.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FilledButton.icon(
              style: style(strong: false),
              onPressed: () => onDial(c.phone),
              icon: const Icon(Icons.person_rounded),
              label: Text('Call ${c.name.isEmpty ? c.phone : c.name}'),
            ),
          ),
      ],
    );
  }
}
