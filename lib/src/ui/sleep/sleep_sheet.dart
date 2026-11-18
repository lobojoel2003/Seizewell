import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../widgets/common.dart';

const sleepQualityLabels = ['Very poor', 'Poor', 'OK', 'Good', 'Great'];

/// Bottom sheet to log (or edit) one night of sleep. [night] is the date the
/// person woke up.
Future<void> showSleepSheet(
  BuildContext context, {
  required DateTime night,
  SleepLog? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _SleepSheet(night: night, existing: existing),
  );
}

class _SleepSheet extends StatefulWidget {
  const _SleepSheet({required this.night, this.existing});

  final DateTime night;
  final SleepLog? existing;

  @override
  State<_SleepSheet> createState() => _SleepSheetState();
}

class _SleepSheetState extends State<_SleepSheet> {
  late DateTime _night = dateOnly(widget.existing?.night ?? widget.night);
  late double _hours = widget.existing?.hours ?? 7.5;
  late int? _quality = widget.existing?.quality ?? 3;
  late final _notes = TextEditingController(text: widget.existing?.notes);

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickNight() async {
    final now = context.services.clock.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _night,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Night ending on',
    );
    if (picked != null) setState(() => _night = dateOnly(picked));
  }

  Future<void> _save() async {
    await context.services.db.upsertSleep(
      night: _night,
      hours: _hours,
      quality: _quality,
      notes: _notes.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await context.services.db.deleteSleep(widget.existing!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sleep',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: _pickNight,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(
                    'Night ending ${formatDateLong(_night)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              formatHours(_hours),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Slider(
            value: _hours,
            min: 0,
            max: 14,
            divisions: 56,
            label: formatHours(_hours),
            onChanged: (v) => setState(() => _hours = v),
          ),
          const SizedBox(height: 8),
          Text('How well did they sleep?', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var q = 1; q <= 5; q++)
                ChoiceChip(
                  label: Text(sleepQualityLabels[q - 1]),
                  selected: _quality == q,
                  onSelected: (_) => setState(() => _quality = q),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Notes (woke up at night, late bedtime…)',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save')),
          if (widget.existing != null)
            TextButton(
              onPressed: () async {
                final ok = await confirm(
                  context,
                  title: 'Delete this night?',
                  message: 'The sleep entry will be removed.',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
                if (ok) await _delete();
              },
              child: const Text('Delete'),
            ),
        ],
      ),
    );
  }
}
