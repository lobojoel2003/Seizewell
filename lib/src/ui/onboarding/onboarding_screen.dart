import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../data/demo_data.dart';
import '../../domain/types.dart';
import '../theme.dart';
import '../widgets/app_logo.dart';

/// First-run setup: what Seizewell is, who uses it, and the essentials of
/// the emergency plan. Everything is optional and can be changed later.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final AppServices _s = context.services;
  final _pages = PageController();
  int _page = 0;
  Reporter _role = Reporter.caregiver;
  final _name = TextEditingController();
  late final _rescue = TextEditingController(
    text: _s.settings.plan.rescueMedication,
  );
  late final _dose = TextEditingController(text: _s.settings.plan.rescueDose);
  late final _number = TextEditingController(
    text: _s.settings.plan.emergencyNumber,
  );
  bool _busy = false;

  static const _count = 4;

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    _rescue.dispose();
    _dose.dispose();
    _number.dispose();
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    _pages.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish({bool sample = false}) async {
    setState(() => _busy = true);
    final st = _s.settings;
    if (sample) {
      await loadDemoData(_s.db, st, today: _s.clock.now());
    } else {
      await st.setRole(_role);
      await st.setPatientName(_name.text);
      await st.setPlan(
        st.plan.copyWith(
          rescueMedication: _rescue.text.trim(),
          rescueDose: _dose.text.trim(),
          emergencyNumber: _number.text.trim().isEmpty
              ? st.plan.emergencyNumber
              : _number.text.trim(),
        ),
      );
      await _s.alerts.requestPermission();
    }
    await st.setOnboardingDone(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _welcome(theme),
                  _who(theme),
                  _plan(theme),
                  _alerts(theme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  for (var i = 0; i < _count; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _page ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const Spacer(),
                  FilledButton(
                    key: const Key('onboarding-next'),
                    onPressed: _busy
                        ? null
                        : _page == _count - 1
                        ? () => _finish()
                        : _next,
                    child: Text(_page == _count - 1 ? 'Get started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageShell(ThemeData theme, {required List<Widget> children}) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: children,
    );
  }

  Widget _title(ThemeData theme, String text) => Text(
    text,
    style: theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    ),
  );

  Widget _lead(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 24),
    child: Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.45,
      ),
    ),
  );

  Widget _point(ThemeData theme, IconData icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcome(ThemeData theme) => _pageShell(
    theme,
    children: [
      const Align(alignment: Alignment.centerLeft, child: AppLogo(size: 72)),
      const SizedBox(height: 24),
      _title(theme, 'A calm, private\nseizure diary'),
      _lead(
        theme,
        'For people with epilepsy and the people who look after them.',
      ),
      _point(
        theme,
        Icons.touch_app_rounded,
        'One tap to time a seizure',
        'A huge button and a clear timer. Details can wait.',
      ),
      _point(
        theme,
        Icons.health_and_safety_rounded,
        'Your emergency plan, when it matters',
        'At 5 minutes the timer turns red and shows your rescue steps.',
      ),
      _point(
        theme,
        Icons.picture_as_pdf_rounded,
        'A one-page report for the clinic',
        'Calendar, seizure types and medication changes at a glance.',
      ),
      _point(
        theme,
        Icons.lock_rounded,
        'Stays on this phone',
        'Encrypted. No account, no cloud, no tracking.',
      ),
      const SizedBox(height: 8),
      Center(
        child: TextButton(
          onPressed: _busy ? null : () => _finish(sample: true),
          child: const Text('Explore with sample data'),
        ),
      ),
    ],
  );

  Widget _who(ThemeData theme) => _pageShell(
    theme,
    children: [
      _title(theme, 'Who is using\nSeizewell?'),
      _lead(theme, 'This sets who new entries are logged by.'),
      SegmentedButton<Reporter>(
        segments: const [
          ButtonSegment(
            value: Reporter.patient,
            label: Text('I have epilepsy'),
            icon: Icon(Icons.person_rounded),
          ),
          ButtonSegment(
            value: Reporter.caregiver,
            label: Text('I’m a caregiver'),
            icon: Icon(Icons.family_restroom_rounded),
          ),
        ],
        selected: {_role},
        onSelectionChanged: (v) => setState(() => _role = v.first),
      ),
      const SizedBox(height: 24),
      TextField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Patient’s name (optional)',
          helperText: 'Only printed on the clinic report.',
        ),
      ),
    ],
  );

  Widget _plan(ThemeData theme) => _pageShell(
    theme,
    children: [
      _title(theme, 'Your emergency\nplan'),
      _lead(
        theme,
        'If a seizure lasts 5 minutes, the timer shows this. Copy it from '
        'the plan your neurologist gave you, or skip it for now.',
      ),
      TextField(
        controller: _rescue,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Rescue medication',
          hintText: 'e.g. Midazolam nasal spray',
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _dose,
        decoration: const InputDecoration(
          labelText: 'Dose',
          hintText: 'e.g. 5 mg, one spray',
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _number,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'Emergency number'),
      ),
      const SizedBox(height: 16),
      Text(
        'You can add contacts and your neurologist’s steps later under '
        'More → Emergency plan.',
        style: theme.textTheme.bodySmall,
      ),
    ],
  );

  Widget _alerts(ThemeData theme) => _pageShell(
    theme,
    children: [
      _title(theme, 'Alerts that\nkeep going'),
      _lead(
        theme,
        'While the timer runs, Seizewell shows a live stopwatch in your '
        'notifications and alerts you at 5 minutes — even if you switch to '
        'the phone app to call for help.',
      ),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [brandNight, brandDeep]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.timer_rounded, color: Colors.white, size: 32),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Seizure timer running\nStarted 14:02 · alert at 05:00',
                style: TextStyle(color: Colors.white, height: 1.4),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'When you tap Get started, your phone will ask to allow '
        'notifications.',
        style: theme.textTheme.bodyMedium,
      ),
    ],
  );
}
