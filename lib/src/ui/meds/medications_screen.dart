import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../../domain/types.dart';
import '../insights/trend_chart.dart' show describeChange;
import '../widgets/common.dart';
import 'medication_editor_screen.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'meds-fab',
        onPressed: () =>
            Navigator.of(context).push(MedicationEditorScreen.route()),
        icon: const Icon(Icons.add),
        label: const Text('Add medication'),
      ),
      body: StreamBuilder<List<Medication>>(
        stream: s.db.watchMedications(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final meds = snap.data!;
          if (meds.isEmpty) {
            return const EmptyState(
              icon: Icons.medication_rounded,
              title: 'No medications yet',
              message:
                  'Add daily and rescue medications. Starts, dose changes '
                  'and stops are marked on the clinic report, so the '
                  'neurologist can see what helped.',
            );
          }
          final daily = meds
              .where((m) => m.active && m.kind == MedicationKind.maintenance)
              .toList();
          final rescue = meds
              .where((m) => m.active && m.kind == MedicationKind.rescue)
              .toList();
          final past = meds.where((m) => !m.active).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            children: [
              if (daily.isNotEmpty) ...[
                const SectionHeader('Daily'),
                _MedGroup(meds: daily),
              ],
              if (rescue.isNotEmpty) ...[
                const SectionHeader('Rescue'),
                _MedGroup(meds: rescue),
              ],
              if (past.isNotEmpty) ...[
                const SectionHeader('Stopped'),
                _MedGroup(meds: past),
              ],
              const SectionHeader('History'),
              const _History(),
            ],
          );
        },
      ),
    );
  }
}

class _MedGroup extends StatelessWidget {
  const _MedGroup({required this.meds});

  final List<Medication> meds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < meds.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 72),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
              leading: CircleAvatar(
                backgroundColor: meds[i].kind == MedicationKind.rescue
                    ? theme.colorScheme.errorContainer
                    : theme.colorScheme.primaryContainer,
                child: Icon(
                  meds[i].kind == MedicationKind.rescue
                      ? Icons.emergency_rounded
                      : Icons.medication_rounded,
                  color: meds[i].kind == MedicationKind.rescue
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                meds[i].name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                [
                  meds[i].dose,
                  meds[i].schedule,
                ].where((x) => x.isNotEmpty).join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context)
                  .push(MedicationEditorScreen.route(medicationId: meds[i].id)),
            ),
          ],
        ],
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History();

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final theme = Theme.of(context);
    return StreamBuilder<List<MedicationChangeEntry>>(
      stream: s.db.watchMedicationChanges(),
      builder: (context, snap) {
        final changes = snap.data ?? const [];
        if (changes.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                for (final c in changes.take(30))
                  ListTile(
                    dense: true,
                    leading: Icon(switch (c.change.kind) {
                      MedicationChangeKind.started =>
                        Icons.play_circle_outline_rounded,
                      MedicationChangeKind.doseChanged =>
                        Icons.swap_vert_circle_outlined,
                      MedicationChangeKind.stopped =>
                        Icons.stop_circle_outlined,
                    }, color: theme.colorScheme.primary),
                    title: Text(describeChange(c)),
                    subtitle: Text(
                      [
                        formatDate(c.change.date),
                        if (c.change.note.isNotEmpty) c.change.note,
                      ].join(' · '),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
