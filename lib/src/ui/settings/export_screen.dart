import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../data/database.dart';
import '../../data/queries.dart';
import '../../services/export/csv_export.dart';
import '../../services/export/fhir_export.dart';
import '../../services/platform_services.dart';
import '../widgets/common.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ExportScreen());

  Future<void> _csv(BuildContext context) async {
    final s = context.services;
    final date = formatIsoDate(s.clock.now());
    await s.platform.shareFiles([
      ShareableFile.text(
        'seizewell-seizures-$date.csv',
        seizuresCsv(await s.db.allSeizures()),
        'text/csv',
      ),
      ShareableFile.text(
        'seizewell-medications-$date.csv',
        medicationsCsv(
          await s.db.allMedications(),
          await s.db.allMedicationChanges(),
        ),
        'text/csv',
      ),
      ShareableFile.text(
        'seizewell-sleep-$date.csv',
        sleepCsv(await s.db.allSleep()),
        'text/csv',
      ),
    ], subject: 'Seizewell CSV export');
  }

  Future<void> _fhir(BuildContext context) async {
    final s = context.services;
    final now = s.clock.now();
    final bundle = buildFhirBundle(
      seizures: await s.db.allSeizures(),
      sleep: await s.db.allSleep(),
      medications: await s.db.allMedications(),
      medicationChanges: await s.db.allMedicationChanges(),
      generatedAt: now,
      patientName: s.settings.patientName,
      birthDate: s.settings.dateOfBirth,
    );
    await s.platform.shareFiles([
      ShareableFile.text(
        'seizewell-fhir-${formatIsoDate(now)}.json',
        encodeFhirBundle(bundle),
        'application/fhir+json',
      ),
    ], subject: 'Seizewell FHIR export');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Export data')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Text(
            'Exports are created on this phone and handed to the app you '
            'pick in the share sheet. They are not encrypted — share them '
            'only with people you trust.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            icon: Icons.table_chart_rounded,
            title: 'Spreadsheet (CSV)',
            body:
                'Three files: seizures, medication changes and sleep. Opens '
                'in Excel, Numbers or Google Sheets.',
            onTap: () => _csv(context),
          ),
          const SizedBox(height: 12),
          InfoCard(
            icon: Icons.medical_information_rounded,
            title: 'FHIR R4 (JSON)',
            body:
                'A Bundle of Observation resources (SNOMED CT seizure, LOINC '
                'sleep duration) and MedicationStatements, for clinic and '
                'research systems.',
            onTap: () => _fhir(context),
          ),
        ],
      ),
    );
  }
}
