import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../../domain/types.dart';
import '../widgets/common.dart';

class MedicationEditorScreen extends StatefulWidget {
  const MedicationEditorScreen({super.key, this.medicationId});

  final int? medicationId;

  static Route<void> route({int? medicationId}) => MaterialPageRoute<void>(
    builder: (_) => MedicationEditorScreen(medicationId: medicationId),
    fullscreenDialog: medicationId == null,
  );

  @override
  State<MedicationEditorScreen> createState() => _MedicationEditorScreenState();
}

class _MedicationEditorScreenState extends State<MedicationEditorScreen> {
  late final AppServices _s = context.services;
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dose = TextEditingController();
  final _schedule = TextEditingController();
  final _notes = TextEditingController();
  MedicationKind _kind = MedicationKind.maintenance;
  late DateTime _date = dateOnly(_s.clock.now());
  Medication? _existing;
  bool _loaded = false;

  bool get _isNew => widget.medicationId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!_isNew) {
      final m = await _s.db.medicationById(widget.medicationId!);
      _existing = m;
      _name.text = m.name;
      _dose.text = m.dose;
      _schedule.text = m.schedule;
      _notes.text = m.notes;
      _kind = m.kind;
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _schedule.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _doseChanged =>
      _existing != null && _existing!.dose.trim() != _dose.text.trim();

  Future<void> _pickDate() async {
    final now = _s.clock.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 30),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = dateOnly(picked));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_isNew) {
      await _s.db.addMedication(
        name: _name.text,
        kind: _kind,
        dose: _dose.text,
        schedule: _schedule.text,
        notes: _notes.text,
        startedOn: _date,
      );
    } else {
      await _s.db.updateMedication(
        _existing!.copyWith(
          name: _name.text.trim(),
          kind: _kind,
          dose: _dose.text.trim(),
          schedule: _schedule.text.trim(),
          notes: _notes.text.trim(),
        ),
        changedOn: _date,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _stopOrRestart() async {
    final m = _existing!;
    final now = _s.clock.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 30),
      lastDate: now,
      helpText: m.active ? 'Stopped on' : 'Restarted on',
    );
    if (date == null) return;
    if (m.active) {
      await _s.db.stopMedication(m.id, date);
    } else {
      await _s.db.restartMedication(m.id, date, _dose.text.trim());
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete ${_existing!.name}?',
      message:
          'This also removes its history from reports. To keep the history, '
          'mark it as stopped instead.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    await _s.db.deleteMedication(_existing!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Add medication' : 'Edit medication'),
        actions: [
          if (!_isNew)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
              onPressed: _loaded ? _save : null,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  SegmentedButton<MedicationKind>(
                    segments: [
                      for (final k in MedicationKind.values)
                        ButtonSegment(value: k, label: Text(k.label)),
                    ],
                    selected: {_kind},
                    onSelectionChanged: (v) => setState(() => _kind = v.first),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: _kind == MedicationKind.rescue
                          ? 'e.g. Midazolam nasal spray'
                          : 'e.g. Levetiracetam',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dose,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Dose',
                      hintText: 'e.g. 500 mg',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _schedule,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: _kind == MedicationKind.rescue
                          ? 'When to give it'
                          : 'Schedule',
                      hintText: _kind == MedicationKind.rescue
                          ? 'e.g. After 5 minutes of seizure'
                          : 'e.g. Twice daily',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  if (_isNew || _doseChanged) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.event_rounded),
                        title: Text(_isNew ? 'Started on' : 'Dose changed on'),
                        subtitle: _isNew
                            ? null
                            : const Text('Marked on the report timeline'),
                        trailing: Text(
                          formatDate(_date),
                          style: theme.textTheme.titleSmall,
                        ),
                        onTap: _pickDate,
                      ),
                    ),
                  ],
                  if (!_isNew) ...[
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _stopOrRestart,
                      icon: Icon(
                        _existing!.active
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                      ),
                      label: Text(
                        _existing!.active
                            ? 'Mark as stopped'
                            : 'Restart this medication',
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
