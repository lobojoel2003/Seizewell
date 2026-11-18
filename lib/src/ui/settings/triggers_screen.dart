import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../widgets/common.dart';

class TriggersScreen extends StatelessWidget {
  const TriggersScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const TriggersScreen());

  Future<void> _add(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a trigger'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          textCapitalization: TextCapitalization.sentences,
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
    if (name != null && name.trim().isNotEmpty && context.mounted) {
      await context.services.db.addTrigger(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    return Scaffold(
      appBar: AppBar(title: const Text('Triggers')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'triggers-fab',
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: const Text('Add trigger'),
      ),
      body: StreamBuilder<List<TriggerTag>>(
        stream: s.db.watchTriggers(includeArchived: true),
        builder: (context, snap) {
          final tags = snap.data ?? const <TriggerTag>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            children: [
              const Text(
                'Turn off triggers you never use to keep the list short. '
                'Past entries keep their triggers.',
              ),
              const SectionHeader('Shown when logging'),
              Card(
                child: Column(
                  children: [
                    for (final t in tags)
                      SwitchListTile(
                        title: Text(t.name),
                        subtitle: t.builtIn ? null : const Text('Custom'),
                        value: !t.archived,
                        onChanged: (on) => s.db.setTriggerArchived(t.id, !on),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
