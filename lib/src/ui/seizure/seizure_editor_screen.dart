import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../../domain/types.dart';
import '../widgets/common.dart';

/// Adds or edits the details of a seizure. Used after the one-tap timer and
/// for logging a seizure after the fact.
class SeizureEditorScreen extends StatefulWidget {
  const SeizureEditorScreen({super.key, this.seizureId});

  final int? seizureId;

  static Route<void> route({int? seizureId}) => MaterialPageRoute<void>(
    builder: (_) => SeizureEditorScreen(seizureId: seizureId),
    fullscreenDialog: seizureId == null,
  );

  @override
  State<SeizureEditorScreen> createState() => _SeizureEditorScreenState();
}

class _SeizureEditorScreenState extends State<SeizureEditorScreen> {
  late final AppServices _s = context.services;
  bool _loaded = false;
  bool _saving = false;

  late DateTime _start;
  final _minutes = TextEditingController();
  final _seconds = TextEditingController();
  final _notes = TextEditingController();
  final _rescueMed = TextEditingController();
  bool _durationKnown = true;
  SeizureType _type = SeizureType.unknown;
  final Set<int> _triggers = {};
  bool _aura = false;
  bool _duringSleep = false;
  bool _injury = false;
  bool _emergency = false;
  bool _rescue = false;
  DateTime? _rescueAt;
  Reporter _loggedBy = Reporter.caregiver;
  Seizure? _existing;

  bool get _isNew => widget.seizureId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_isNew) {
      final now = _s.clock.now();
      _start = DateTime(now.year, now.month, now.day, now.hour, now.minute);
      _minutes.text = '1';
      _seconds.text = '0';
      _loggedBy = _s.settings.role;
      _rescueMed.text = _s.settings.plan.rescueMedication;
    } else {
      final entry = await _s.db.seizureEntry(widget.seizureId!);
      if (entry == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      final s = entry.seizure;
      _existing = s;
      _start = s.startedAt;
      final d = (s.endedAt ?? s.startedAt).difference(s.startedAt);
      _minutes.text = '${d.inMinutes}';
      _seconds.text = '${d.inSeconds.remainder(60)}';
      _durationKnown = s.durationKnown;
      _type = s.type;
      _triggers.addAll(entry.triggers.map((t) => t.id));
      _aura = s.aura;
      _duringSleep = s.duringSleep;
      _injury = s.injury;
      _emergency = s.emergencyCare;
      _rescue = s.rescueGivenAt != null;
      _rescueAt = s.rescueGivenAt;
      _rescueMed.text = s.rescueMedication ?? _s.settings.plan.rescueMedication;
      _loggedBy = s.loggedBy;
      _notes.text = s.notes;
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _minutes.dispose();
    _seconds.dispose();
    _notes.dispose();
    _rescueMed.dispose();
    super.dispose();
  }

  Duration get _duration => Duration(
    minutes: int.tryParse(_minutes.text.trim()) ?? 0,
    seconds: int.tryParse(_seconds.text.trim()) ?? 0,
  );

  Future<void> _pickDate() async {
    final now = _s.clock.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _start.isAfter(now) ? now : _start,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _start = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _start.hour,
        _start.minute,
        _start.second,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (picked == null) return;
    setState(() {
      _start = DateTime(
        _start.year,
        _start.month,
        _start.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _pickRescueTime() async {
    final initial = _rescueAt ?? _start.add(_s.settings.plan.alertAfter);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: 'Rescue medication given at',
    );
    if (picked == null) return;
    var at = DateTime(
      _start.year,
      _start.month,
      _start.day,
      picked.hour,
      picked.minute,
    );
    if (at.isBefore(_start.subtract(const Duration(minutes: 1)))) {
      at = at.add(const Duration(days: 1));
    }
    setState(() => _rescueAt = at);
  }

  Future<void> _addTrigger() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a trigger'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 60,
          decoration: const InputDecoration(hintText: 'e.g. Video games'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    final tag = await _s.db.addTrigger(name);
    setState(() => _triggers.add(tag.id));
  }

  String? _validate() {
    final now = _s.clock.now();
    if (_start.isAfter(now.add(const Duration(minutes: 1)))) {
      return 'The start time is in the future.';
    }
    if (_durationKnown) {
      final d = _duration;
      if (d <= Duration.zero) return 'Enter how long the seizure lasted.';
      if (d > const Duration(hours: 12)) {
        return 'That duration looks too long. Check the minutes.';
      }
    }
    return null;
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      showMessage(context, error);
      return;
    }
    setState(() => _saving = true);
    final end = _durationKnown ? _start.add(_duration) : _start;
    final companion = SeizuresCompanion(
      id: _isNew ? const Value.absent() : Value(widget.seizureId!),
      startedAt: Value(_start),
      endedAt: Value(end),
      durationKnown: Value(_durationKnown),
      type: Value(_type),
      aura: Value(_aura),
      duringSleep: Value(_duringSleep),
      injury: Value(_injury),
      emergencyCare: Value(_emergency),
      rescueGivenAt: Value(
        _rescue ? (_rescueAt ?? _start.add(_s.settings.plan.alertAfter)) : null,
      ),
      rescueMedication: Value(
        _rescue && _rescueMed.text.trim().isNotEmpty
            ? _rescueMed.text.trim()
            : null,
      ),
      loggedBy: Value(_loggedBy),
      notes: Value(_notes.text.trim()),
      detailsCompleted: const Value(true),
      createdAt: _existing == null
          ? const Value.absent()
          : Value(_existing!.createdAt),
    );
    await _s.db.saveSeizure(companion, _triggers, now: _s.clock.now());
    if (!mounted) return;
    unawaited(HapticFeedback.lightImpact());
    Navigator.of(context).pop();
    showMessage(context, 'Seizure saved');
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete this seizure?',
      message: 'It will be removed from the diary and from reports.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _s.db.deleteSeizure(widget.seizureId!);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Log a seizure' : 'Seizure details'),
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
              key: const Key('save-seizure'),
              style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
              onPressed: _loaded && !_saving ? _save : null,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              children: [
                const SectionHeader('When'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.event_rounded),
                        title: const Text('Date'),
                        trailing: Text(
                          formatDate(_start),
                          style: theme.textTheme.titleSmall,
                        ),
                        onTap: _pickDate,
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.schedule_rounded),
                        title: const Text('Started at'),
                        trailing: Text(
                          formatTime(_start),
                          style: theme.textTheme.titleSmall,
                        ),
                        onTap: _pickTime,
                      ),
                      const Divider(height: 1, indent: 56),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined),
                            const SizedBox(width: 16),
                            const Expanded(child: Text('Lasted')),
                            SizedBox(
                              width: 72,
                              child: TextField(
                                key: const Key('duration-minutes'),
                                controller: _minutes,
                                enabled: _durationKnown,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  suffixText: 'min',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 72,
                              child: TextField(
                                key: const Key('duration-seconds'),
                                controller: _seconds,
                                enabled: _durationKnown,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  suffixText: 's',
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CheckboxListTile(
                        value: !_durationKnown,
                        onChanged: (v) =>
                            setState(() => _durationKnown = !(v ?? false)),
                        title: const Text('Not sure how long'),
                        subtitle: const Text(
                          'For example, nobody saw it start',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),
                SectionHeader(
                  'What happened',
                  trailing: TextButton(
                    onPressed: () => _showTypeGuide(context),
                    child: const Text('Which type?'),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final t in SeizureType.values)
                              ChoiceChip(
                                avatar: TypeDot(t),
                                label: Text(t.short),
                                selected: _type == t,
                                showCheckmark: false,
                                onSelected: (_) => setState(() => _type = t),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            key: ValueKey(_type),
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _type.label,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _type.description,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SectionHeader('Possible triggers'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: StreamBuilder<List<TriggerTag>>(
                      stream: _s.db.watchTriggers(includeArchived: true),
                      builder: (context, snap) {
                        final tags = (snap.data ?? const <TriggerTag>[])
                            .where(
                              (t) => !t.archived || _triggers.contains(t.id),
                            )
                            .toList();
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final t in tags)
                              FilterChip(
                                label: Text(t.name),
                                selected: _triggers.contains(t.id),
                                onSelected: (on) => setState(
                                  () => on
                                      ? _triggers.add(t.id)
                                      : _triggers.remove(t.id),
                                ),
                              ),
                            ActionChip(
                              avatar: const Icon(Icons.add, size: 18),
                              label: const Text('Add'),
                              onPressed: _addTrigger,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SectionHeader('Details'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _aura,
                        onChanged: (v) => setState(() => _aura = v),
                        title: const Text('Warning or aura beforehand'),
                      ),
                      SwitchListTile(
                        value: _duringSleep,
                        onChanged: (v) => setState(() => _duringSleep = v),
                        title: const Text('Happened during sleep'),
                      ),
                      SwitchListTile(
                        value: _injury,
                        onChanged: (v) => setState(() => _injury = v),
                        title: const Text('Injury'),
                      ),
                      SwitchListTile(
                        value: _emergency,
                        onChanged: (v) => setState(() => _emergency = v),
                        title: const Text('Ambulance, ER or hospital'),
                      ),
                      SwitchListTile(
                        key: const Key('rescue-switch'),
                        value: _rescue,
                        onChanged: (v) => setState(() => _rescue = v),
                        title: const Text('Rescue medication given'),
                      ),
                      if (_rescue) ...[
                        ListTile(
                          leading: const Icon(Icons.schedule_rounded),
                          title: const Text('Given at'),
                          trailing: Text(
                            formatTime(
                              _rescueAt ??
                                  _start.add(_s.settings.plan.alertAfter),
                            ),
                          ),
                          onTap: _pickRescueTime,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                          child: TextField(
                            controller: _rescueMed,
                            decoration: const InputDecoration(
                              labelText: 'Rescue medication',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SectionHeader('Notes'),
                TextField(
                  controller: _notes,
                  minLines: 3,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText:
                        'What did you see? How long until they were back to '
                        'normal? Anything unusual today?',
                  ),
                ),
                const SectionHeader('Logged by'),
                SegmentedButton<Reporter>(
                  segments: [
                    for (final r in Reporter.values)
                      ButtonSegment(value: r, label: Text(r.label)),
                  ],
                  selected: {_loggedBy},
                  onSelectionChanged: (v) =>
                      setState(() => _loggedBy = v.first),
                ),
              ],
            ),
    );
  }

  void _showTypeGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              Text(
                'Seizure types',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Based on the ILAE 2017 classification. If you are unsure, '
                'pick "Not sure" and describe what you saw.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              for (final t in SeizureType.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: TypeDot(t, size: 14),
                  title: Text(
                    t.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(t.description),
                  onTap: () {
                    setState(() => _type = t);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
