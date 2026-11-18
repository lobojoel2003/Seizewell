import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../data/queries.dart';
import '../../domain/emergency_plan.dart';
import '../widgets/common.dart';

/// The family's seizure action plan, shown on the timer when a seizure
/// lasts too long.
class EmergencyPlanScreen extends StatefulWidget {
  const EmergencyPlanScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const EmergencyPlanScreen());

  @override
  State<EmergencyPlanScreen> createState() => _EmergencyPlanScreenState();
}

class _ContactFields {
  _ContactFields([EmergencyContact? c])
    : name = TextEditingController(text: c?.name),
      phone = TextEditingController(text: c?.phone);

  final TextEditingController name;
  final TextEditingController phone;

  void dispose() {
    name.dispose();
    phone.dispose();
  }
}

class _EmergencyPlanScreenState extends State<EmergencyPlanScreen> {
  late final AppServices _s = context.services;
  late EmergencyPlan _plan = _s.settings.plan;
  late final _rescue = TextEditingController(text: _plan.rescueMedication);
  late final _dose = TextEditingController(text: _plan.rescueDose);
  late final _number = TextEditingController(text: _plan.emergencyNumber);
  late final _instructions = TextEditingController(text: _plan.instructions);
  late final _gap = TextEditingController(
    text: _plan.minHoursBetweenRescueDoses?.toString() ?? '',
  );
  late final List<_ContactFields> _contacts = [
    for (final c in _plan.contacts) _ContactFields(c),
  ];

  @override
  void dispose() {
    for (final c in [_rescue, _dose, _number, _instructions, _gap]) {
      c.dispose();
    }
    for (final c in _contacts) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final number = _number.text.trim();
    if (number.isEmpty) {
      showMessage(context, 'Enter the emergency number to call.');
      return;
    }
    await _s.settings.setPlan(
      _plan.copyWith(
        rescueMedication: _rescue.text.trim(),
        rescueDose: _dose.text.trim(),
        emergencyNumber: number,
        instructions: _instructions.text.trim(),
        minHoursBetweenRescueDoses: () => int.tryParse(_gap.text.trim()),
        contacts: [
          for (final c in _contacts)
            if (c.phone.text.trim().isNotEmpty)
              EmergencyContact(
                name: c.name.text.trim(),
                phone: c.phone.text.trim(),
              ),
        ],
      ),
    );
    // A seizure being timed right now follows the new thresholds.
    final active = await _s.db.activeSeizure();
    if (active != null) await _s.alerts.sync(active, _s.settings.plan);
    if (!mounted) return;
    Navigator.pop(context);
    showMessage(context, 'Emergency plan saved');
  }

  Widget _minutesStepper({
    required String label,
    required String help,
    required Duration value,
    required ValueChanged<Duration> onChanged,
    int min = 1,
    int max = 30,
  }) {
    final theme = Theme.of(context);
    final minutes = value.inMinutes;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  help,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Less',
            onPressed: minutes > min
                ? () => onChanged(Duration(minutes: minutes - 1))
                : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$minutes min',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'More',
            onPressed: minutes < max
                ? () => onChanged(Duration(minutes: minutes + 1))
                : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency plan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
              onPressed: _save,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: [
          Text(
            'Copy this from the seizure action plan your neurologist gave '
            'you. It appears on the timer screen when it matters.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SectionHeader('Timing'),
          Card(
            child: Column(
              children: [
                _minutesStepper(
                  label: 'Warn after',
                  help: 'The timer turns red and shows this plan.',
                  value: _plan.alertAfter,
                  onChanged: (d) =>
                      setState(() => _plan = _plan.copyWith(alertAfter: d)),
                ),
                const Divider(height: 1),
                _minutesStepper(
                  label: 'Call for help after rescue',
                  help: 'If still seizing this long after the rescue dose.',
                  value: _plan.callAfterRescue,
                  onChanged: (d) => setState(
                    () => _plan = _plan.copyWith(callAfterRescue: d),
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader('Rescue medication'),
          TextField(
            controller: _rescue,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Medication',
              hintText: 'e.g. Midazolam nasal spray',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dose,
            decoration: const InputDecoration(
              labelText: 'Dose and how to give it',
              hintText: 'e.g. 5 mg, one spray in one nostril',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _gap,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Minimum hours between doses (optional)',
              helperText: 'Shown on the Today screen after a dose is given.',
            ),
          ),
          const SectionHeader('Who to call'),
          TextField(
            controller: _number,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Emergency number',
              prefixIcon: Icon(Icons.local_hospital_rounded),
            ),
          ),
          for (var i = 0; i < _contacts.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _contacts[i].name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _contacts[i].phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove contact',
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        setState(() => _contacts.removeAt(i).dispose()),
                  ),
                ],
              ),
            ),
          if (_contacts.length < 3)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    setState(() => _contacts.add(_ContactFields())),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Add a contact'),
              ),
            ),
          const SectionHeader('Steps from your neurologist'),
          TextField(
            controller: _instructions,
            minLines: 4,
            maxLines: 10,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText:
                  'e.g. Give rescue spray at 5 minutes. Call 911 if still '
                  'seizing 10 minutes later. Recovery position afterwards.',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Seizewell does not give medical advice. Follow the plan agreed '
            'with your care team.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
