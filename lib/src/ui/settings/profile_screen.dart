import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../domain/types.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ProfileScreen());

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AppServices _s = context.services;
  late final _name = TextEditingController(text: _s.settings.patientName);
  late DateTime? _dob = _s.settings.dateOfBirth;
  late Reporter _role = _s.settings.role;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = _s.clock.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Date of birth',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    await _s.settings.setPatientName(_name.text);
    await _s.settings.setDateOfBirth(_dob);
    await _s.settings.setRole(_role);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Patient name',
              helperText: 'Printed on the clinic report. Optional.',
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cake_rounded),
              title: const Text('Date of birth'),
              subtitle: const Text('Optional'),
              trailing: Text(_dob == null ? 'Not set' : formatDate(_dob!)),
              onTap: _pickDob,
              onLongPress: () => setState(() => _dob = null),
            ),
          ),
          const SectionHeader('Who uses this phone?'),
          SegmentedButton<Reporter>(
            segments: const [
              ButtonSegment(
                value: Reporter.patient,
                label: Text('The patient'),
                icon: Icon(Icons.person_rounded),
              ),
              ButtonSegment(
                value: Reporter.caregiver,
                label: Text('A caregiver'),
                icon: Icon(Icons.family_restroom_rounded),
              ),
            ],
            selected: {_role},
            onSelectionChanged: (v) => setState(() => _role = v.first),
          ),
          const SizedBox(height: 8),
          Text(
            'New entries are marked as logged by this person. You can change '
            'it on each entry.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
